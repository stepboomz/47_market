-- Add payment_method column to orders table
-- This column stores the payment method used: 'qr' (PromptPay) or 'cash'

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS payment_method TEXT;

-- Add comment to describe the column
COMMENT ON COLUMN orders.payment_method IS 'Payment method used: qr (PromptPay) or cash';

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_orders_payment_method ON orders(payment_method);

