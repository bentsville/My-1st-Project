-- Create database (if not exists)
CREATE DATABASE corporate_db;

\c corporate_db;

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    failed_attempts INT DEFAULT 0,
    account_locked BOOLEAN DEFAULT FALSE
);

-- Accounts table
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    balance NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(10) NOT NULL DEFAULT 'MYR',
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Transactions table
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    reference VARCHAR(50) NOT NULL,
    from_account VARCHAR(20) NOT NULL,
    to_account VARCHAR(20) NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Batches table
CREATE TABLE batches (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Batch Transactions join table
CREATE TABLE batch_transactions (
    batch_id INT NOT NULL,
    transaction_id INT NOT NULL,
    PRIMARY KEY (batch_id, transaction_id),
    FOREIGN KEY (batch_id) REFERENCES batches(id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
);

-- Approvals table
CREATE TABLE approvals (
    id SERIAL PRIMARY KEY,
    transaction_id INT NOT NULL,
    approver_id INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    FOREIGN KEY (approver_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Statements (audit log of account transactions)
CREATE TABLE statements (
    id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_id INT NOT NULL,
    entry_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount NUMERIC(15,2) NOT NULL,
    balance_after NUMERIC(15,2) NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
);

-- Insert demo users (passwords are plain text here for testing; hash them in production)
INSERT INTO users (username, password, role) VALUES
('corpuser', 'password', 'USER'),
('approver', 'password', 'APPROVER');

-- Insert demo accounts
INSERT INTO accounts (account_number, account_name, balance, currency, user_id) VALUES
('100001', 'Corporate Main Account', 500000.00, 'MYR', 1),
('100002', 'Corporate Payroll Account', 200000.00, 'MYR', 1);
