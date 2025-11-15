-- Add address column to profiles table
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS address TEXT;

-- Add comment to the column
COMMENT ON COLUMN profiles.address IS 'User address for delivery';

