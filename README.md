# Smart Public Library DVD Collection Management System

A comprehensive blockchain-based system for managing DVD collections in public libraries, built with Clarity smart contracts.

## System Overview

This system consists of five interconnected smart contracts that handle different aspects of DVD collection management:

### 1. Media Cataloging Contract (`media-catalog.clar`)
- Manages movie and documentary inventory tracking
- Handles DVD registration, updates, and availability status
- Tracks genre, release year, and runtime information
- Maintains borrowing history and current status

### 2. Damage Assessment Contract (`damage-assessment.clar`)
- Evaluates scratched or broken DVDs for replacement decisions
- Categorizes damage levels (minor, moderate, severe)
- Calculates replacement costs based on damage severity
- Tracks damage reports and assessment history

### 3. Late Fee Calculation Contract (`late-fee-calculator.clar`)
- Computes overdue charges for media rentals
- Implements tiered fee structure based on days overdue
- Handles fee waivers and adjustments for special cases
- Maintains payment history and outstanding balances

### 4. Popular Title Tracking Contract (`popular-titles.clar`)
- Monitors high-demand movies for additional copy decisions
- Tracks borrowing frequency and wait list lengths
- Identifies trending titles requiring more copies
- Generates acquisition recommendations

### 5. Format Conversion Contract (`format-conversion.clar`)
- Manages transition from DVD to digital streaming
- Tracks availability of digital alternatives
- Handles patron notification for format changes
- Maintains conversion timeline and status updates

## Key Features

- **Immutable Records**: All transactions and changes are permanently recorded
- **Transparent Operations**: Public visibility of library operations and policies
- **Automated Calculations**: Smart contract logic ensures consistent fee and assessment calculations
- **Data Integrity**: Blockchain ensures data cannot be tampered with or lost
- **Decentralized Access**: Multiple library branches can access the same system

## Data Types

### DVD Record Structure
- `dvd-id`: Unique identifier (uint)
- `title`: Movie/documentary title (string-ascii 100)
- `genre`: Category classification (string-ascii 50)
- `release-year`: Publication year (uint)
- `runtime`: Duration in minutes (uint)
- `condition`: Current physical state (string-ascii 20)
- `available`: Checkout availability (bool)
- `total-borrows`: Lifetime checkout count (uint)

### Patron Information
- `patron-id`: Unique library card number (uint)
- `outstanding-fees`: Current balance owed (uint)
- `borrowing-history`: List of previous checkouts
- `current-checkouts`: Active rentals

### Damage Assessment
- `damage-level`: Severity rating (1-5 scale)
- `replacement-cost`: Calculated replacement fee (uint)
- `assessor`: Staff member who evaluated damage (principal)
- `assessment-date`: When evaluation was completed (uint)

## Installation

1. Install Clarinet CLI
2. Clone this repository
3. Run `clarinet check` to validate contracts
4. Run `npm test` to execute the test suite
5. Deploy contracts using `clarinet deploy`

## Usage

### Adding New DVDs
```clarity
(contract-call? .media-catalog add-dvd 
  "The Matrix" 
  "Science Fiction" 
  u1999 
  u136 
  "excellent")
