-- Add user_id column to orders table
-- This migration adds a user_id column to link orders to users

-- Add user_id column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'orders' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE orders ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;
    END IF;
END $$;

-- Create index on user_id for better query performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);

-- Enable RLS on orders table if not already enabled
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Add RLS policy to allow users to see their own orders
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'orders'
          AND policyname = 'Users can view their own orders'
    ) THEN
        CREATE POLICY "Users can view their own orders"
        ON orders FOR SELECT
        USING (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'orders'
          AND policyname = 'Users can insert their own orders'
    ) THEN
        CREATE POLICY "Users can insert their own orders"
        ON orders FOR INSERT
        WITH CHECK (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'orders'
          AND policyname = 'Allow public read access on orders for admin'
    ) THEN
        -- Allow admin to see all orders (you may want to restrict this based on user role)
        CREATE POLICY "Allow public read access on orders for admin"
        ON orders FOR SELECT
        USING (true);
    END IF;
END $$;

