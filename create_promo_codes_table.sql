-- Create promo_codes table
-- This table stores promotional codes that can be applied to orders

CREATE TABLE IF NOT EXISTS promo_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(10,2) NOT NULL CHECK (discount_value > 0),
    min_purchase_amount DECIMAL(10,2) DEFAULT 0 CHECK (min_purchase_amount >= 0),
    max_discount_amount DECIMAL(10,2) CHECK (max_discount_amount IS NULL OR max_discount_amount > 0),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    usage_limit INTEGER CHECK (usage_limit IS NULL OR usage_limit > 0),
    used_count INTEGER DEFAULT 0 CHECK (used_count >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_date_range CHECK (end_date > start_date)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_promo_codes_code ON promo_codes(code);
CREATE INDEX IF NOT EXISTS idx_promo_codes_is_active ON promo_codes(is_active);
CREATE INDEX IF NOT EXISTS idx_promo_codes_dates ON promo_codes(start_date, end_date);

-- Add comment to describe the table
COMMENT ON TABLE promo_codes IS 'Stores promotional codes for discounts on orders';
COMMENT ON COLUMN promo_codes.code IS 'Unique promotional code (e.g., "SAVE20", "WELCOME50")';
COMMENT ON COLUMN promo_codes.discount_type IS 'Type of discount: "percentage" or "fixed"';
COMMENT ON COLUMN promo_codes.discount_value IS 'Discount value: percentage (0-100) or fixed amount';
COMMENT ON COLUMN promo_codes.min_purchase_amount IS 'Minimum purchase amount required to use this code';
COMMENT ON COLUMN promo_codes.max_discount_amount IS 'Maximum discount amount (for percentage type)';
COMMENT ON COLUMN promo_codes.usage_limit IS 'Maximum number of times this code can be used (NULL = unlimited)';
COMMENT ON COLUMN promo_codes.used_count IS 'Number of times this code has been used';

-- Enable Row Level Security
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;

-- Create policy: Allow public read access to active promo codes
CREATE POLICY "Allow public read access to active promo codes"
ON promo_codes FOR SELECT
USING (is_active = TRUE);

-- Create policy: Allow update of used_count (for incrementing usage counter)
-- This allows the app to update used_count when a promo code is used
CREATE POLICY "Allow update used_count on promo codes"
ON promo_codes FOR UPDATE
USING (true)
WITH CHECK (true);

-- Add promo_code_id and discount_amount columns to orders table
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS promo_code_id UUID REFERENCES promo_codes(id),
ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(10,2) DEFAULT 0 CHECK (discount_amount >= 0);

-- Create index for promo_code_id
CREATE INDEX IF NOT EXISTS idx_orders_promo_code_id ON orders(promo_code_id);

-- Add comments
COMMENT ON COLUMN orders.promo_code_id IS 'Reference to the promo code used for this order';
COMMENT ON COLUMN orders.discount_amount IS 'Discount amount applied to this order';

