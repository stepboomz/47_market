-- =========================================
-- Disable Email Confirmation in Supabase
-- =========================================
-- 
-- IMPORTANT: This SQL alone cannot disable email confirmation.
-- You MUST also disable it in Supabase Dashboard:
-- 
-- Steps to disable email confirmation:
-- 1. Go to Supabase Dashboard
-- 2. Navigate to: Authentication > Settings
-- 3. Find "Email Auth" section
-- 4. Toggle OFF "Enable email confirmations"
-- 5. Save changes
--
-- =========================================
-- Auto-confirm users function (optional)
-- =========================================
-- This function can be used to auto-confirm users after signup
-- if you cannot disable email confirmation in the dashboard

CREATE OR REPLACE FUNCTION auto_confirm_user(user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update the user's email_confirmed_at to current timestamp
  -- This effectively confirms the email
  UPDATE auth.users
  SET 
    email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
    confirmed_at = COALESCE(confirmed_at, NOW())
  WHERE id = user_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION auto_confirm_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION auto_confirm_user(UUID) TO anon;

-- =========================================
-- Alternative: Trigger to auto-confirm on signup
-- =========================================
-- This trigger will automatically confirm users when they sign up

CREATE OR REPLACE FUNCTION auto_confirm_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Auto-confirm the user's email
  NEW.email_confirmed_at = COALESCE(NEW.email_confirmed_at, NOW());
  NEW.confirmed_at = COALESCE(NEW.confirmed_at, NOW());
  RETURN NEW;
END;
$$;

-- Create trigger (only if it doesn't exist)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'auto_confirm_user_trigger'
  ) THEN
    CREATE TRIGGER auto_confirm_user_trigger
    BEFORE INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION auto_confirm_new_user();
  END IF;
END $$;

