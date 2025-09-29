-- Fix Demo Credentials Support
-- This migration updates the demo user credentials to match the AuthService expectations

BEGIN;

-- Helper function to safely insert or update user profiles
CREATE OR REPLACE FUNCTION upsert_demo_user_profile(
  p_email TEXT,
  p_full_name TEXT,
  p_role user_role,
  p_phone_number TEXT,
  p_abha_address TEXT,
  p_abha_id TEXT
) RETURNS VOID AS $$
BEGIN
  -- First try to update
  UPDATE public.user_profiles 
  SET 
    phone_number = p_phone_number,
    abha_address = p_abha_address,
    abha_id = p_abha_id,
    full_name = p_full_name,
    role = p_role,
    updated_at = CURRENT_TIMESTAMP
  WHERE email = p_email;
  
  -- If no rows were updated, insert
  IF NOT FOUND THEN
    INSERT INTO public.user_profiles (
      id,
      email,
      full_name,
      role,
      phone_number,
      abha_address, 
      abha_id,
      is_active,
      created_at,
      updated_at
    ) VALUES (
      gen_random_uuid(),
      p_email,
      p_full_name,
      p_role,
      p_phone_number,
      p_abha_address,
      p_abha_id, 
      true,
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP
    );
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Update/Insert demo user profiles
SELECT upsert_demo_user_profile(
  'patient@ayursutra.com',
  'Demo Patient',
  'patient',
  '+919991199911',
  'demo.patient@abdm',
  'PATIENT123456789'
);

SELECT upsert_demo_user_profile(
  'doctor@ayursutra.com',
  'Demo Doctor', 
  'doctor',
  '+919992299922',
  'demo.doctor@abdm',
  'DOCTOR123456789'
);

SELECT upsert_demo_user_profile(
  'chemist@ayursutra.com',
  'Demo Chemist',
  'chemist',
  '+919993399933',
  'demo.chemist@abdm',
  'CHEMIST123456789'
);

-- Create sample data for demo users to make the app functional

-- Insert healthcare center only if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.healthcare_centers 
    WHERE name = 'AyurSutra Demo Center'
  ) THEN
    INSERT INTO public.healthcare_centers (
      name,
      address,
      phone_number,
      email,
      is_verified,
      services_offered
    ) VALUES (
      'AyurSutra Demo Center',
      '{"street": "123 Wellness Street", "city": "Mumbai", "state": "Maharashtra", "country": "India", "pincode": "400001"}'::jsonb,
      '+912212345678',
      'center@ayursutra.com',
      true,
      ARRAY['panchakarma', 'consultation', 'therapy']
    );
  END IF;
END $$;

-- Create demo therapy packages only if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.therapy_packages 
    WHERE name = 'Abhyanga Package'
  ) THEN
    INSERT INTO public.therapy_packages (
      name,
      description,
      price,
      is_active,
      therapy_types,
      duration_days,
      total_sessions
    ) VALUES (
      'Abhyanga Package',
      'Traditional full body oil massage therapy for relaxation and healing',
      2500.00,
      true,
      ARRAY['abhyanga']::therapy_type[],
      7,
      7
    );
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.therapy_packages 
    WHERE name = 'Shirodhara Package'
  ) THEN
    INSERT INTO public.therapy_packages (
      name,
      description,
      price,
      is_active,
      therapy_types,
      duration_days,
      total_sessions
    ) VALUES (
      'Shirodhara Package',
      'Continuous pouring of medicated oil on forehead for mental relaxation',
      3500.00,
      true,
      ARRAY['shirodhara']::therapy_type[],
      5,
      5
    );
  END IF;
END $$;

-- Clean up the helper function
DROP FUNCTION IF EXISTS upsert_demo_user_profile;

COMMIT;