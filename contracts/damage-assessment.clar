;; Damage Assessment Contract
;; Evaluates scratched or broken DVDs for replacement

;; Error constants
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-INVALID-INPUT (err u400))
(define-constant ERR-UNAUTHORIZED (err u401))

;; Data variables
(define-data-var next-assessment-id uint u1)

;; Data maps
(define-map damage-assessments
  { assessment-id: uint }
  {
    dvd-id: uint,
    damage-level: uint,
    replacement-cost: uint,
    assessor: principal,
    assessment-date: uint,
    notes: (string-ascii 200),
    replacement-needed: bool
  }
)

(define-map dvd-damage-history
  { dvd-id: uint }
  { assessments: (list 20 uint) }
)

;; Read-only functions
(define-read-only (get-assessment (assessment-id uint))
  (map-get? damage-assessments { assessment-id: assessment-id })
)

(define-read-only (get-dvd-damage-history (dvd-id uint))
  (default-to
    { assessments: (list) }
    (map-get? dvd-damage-history { dvd-id: dvd-id })
  )
)

(define-read-only (calculate-replacement-cost (damage-level uint) (base-cost uint))
  (if (is-eq damage-level u1)
    u0
    (if (is-eq damage-level u2)
      (/ (* base-cost u25) u100)
      (if (is-eq damage-level u3)
        (/ (* base-cost u50) u100)
        (if (is-eq damage-level u4)
          (/ (* base-cost u75) u100)
          base-cost
        )
      )
    )
  )
)

(define-read-only (needs-replacement (damage-level uint))
  (>= damage-level u4)
)

(define-read-only (get-damage-level-description (damage-level uint))
  (if (is-eq damage-level u1)
    "excellent"
    (if (is-eq damage-level u2)
      "minor-scratches"
      (if (is-eq damage-level u3)
        "moderate-damage"
        (if (is-eq damage-level u4)
          "severe-damage"
          "replacement-required"
        )
      )
    )
  )
)

;; Public functions
(define-public (assess-damage (dvd-id uint) (damage-level uint) (base-cost uint) (notes (string-ascii 200)))
  (let
    (
      (assessment-id (var-get next-assessment-id))
      (replacement-cost (calculate-replacement-cost damage-level base-cost))
      (replacement-needed (needs-replacement damage-level))
      (history (get-dvd-damage-history dvd-id))
    )
    (asserts! (and (>= damage-level u1) (<= damage-level u5)) ERR-INVALID-INPUT)
    (asserts! (> base-cost u0) ERR-INVALID-INPUT)

    (map-set damage-assessments
      { assessment-id: assessment-id }
      {
        dvd-id: dvd-id,
        damage-level: damage-level,
        replacement-cost: replacement-cost,
        assessor: tx-sender,
        assessment-date: block-height,
        notes: notes,
        replacement-needed: replacement-needed
      }
    )

    (map-set dvd-damage-history
      { dvd-id: dvd-id }
      { assessments: (unwrap! (as-max-len? (append (get assessments history) assessment-id) u20) ERR-INVALID-INPUT) }
    )

    (var-set next-assessment-id (+ assessment-id u1))

    (ok {
      assessment-id: assessment-id,
      replacement-cost: replacement-cost,
      replacement-needed: replacement-needed
    })
  )
)

(define-public (update-assessment-notes (assessment-id uint) (new-notes (string-ascii 200)))
  (let
    (
      (assessment-data (unwrap! (get-assessment assessment-id) ERR-NOT-FOUND))
    )
    (asserts! (is-eq (get assessor assessment-data) tx-sender) ERR-UNAUTHORIZED)

    (map-set damage-assessments
      { assessment-id: assessment-id }
      (merge assessment-data { notes: new-notes })
    )

    (ok true)
  )
)

(define-public (bulk-assess-damage (dvd-ids (list 10 uint)) (damage-levels (list 10 uint)) (base-costs (list 10 uint)))
  (let
    (
      (results (map assess-single-damage dvd-ids damage-levels base-costs))
    )
    (ok results)
  )
)

;; Private functions
(define-private (assess-single-damage (dvd-id uint) (damage-level uint) (base-cost uint))
  (assess-damage dvd-id damage-level base-cost "Bulk assessment")
)
