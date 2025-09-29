-- Location: supabase/migrations/20250929110320_add_demo_credentials_support.sql
-- Schema Analysis: Building upon existing AyurSutra healthcare schema
-- Integration Type: Enhancement - Add demo mode support and mobile credentials
-- Dependencies: user_profiles, patient_profiles, doctor_profiles, chemist_profiles

-- Add demo mobile numbers and ABHA addresses for demo mode as specified in requirements
DO $$
DECLARE
    patient_id UUID;
    doctor_id UUID;
    chemist_id UUID;
    admin_id UUID;
BEGIN
    -- Get existing user IDs
    SELECT id INTO patient_id FROM public.user_profiles WHERE email = 'patient@ayursutra.com';
    SELECT id INTO doctor_id FROM public.user_profiles WHERE email = 'doctor@ayursutra.com';
    SELECT id INTO chemist_id FROM public.user_profiles WHERE email = 'chemist@ayursutra.com';
    SELECT id INTO admin_id FROM public.user_profiles WHERE email = 'admin@ayursutra.com';

    -- Update existing user profiles with demo credentials as specified
    UPDATE public.user_profiles SET 
        phone_number = '+919991199911',
        abha_address = 'demo.patient@abdm'
    WHERE id = patient_id;

    UPDATE public.user_profiles SET 
        phone_number = '+919992299922',
        abha_address = 'demo.doctor@abdm'
    WHERE id = doctor_id;

    UPDATE public.user_profiles SET 
        phone_number = '+919993399933',
        abha_address = 'demo.chemist@abdm'
    WHERE id = chemist_id;

    UPDATE public.user_profiles SET 
        phone_number = '+919994499944'
    WHERE id = admin_id;

    -- Add demo ABHA verifications for demo mode
    INSERT INTO public.abha_verifications (user_id, abha_id, verification_status, verified_at, consent_given_at)
    VALUES 
        (patient_id, '12345678901234', 'verified', now(), now()),
        (doctor_id, '98765432109876', 'verified', now(), now()),
        (chemist_id, '11223344556677', 'verified', now(), now())
    ON CONFLICT (user_id, abha_id) DO UPDATE SET
        verification_status = 'verified',
        verified_at = now(),
        consent_given_at = now();

    RAISE NOTICE 'Demo credentials updated successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Demo credentials update failed: %', SQLERRM;
END $$;

-- Function to check if demo mode is enabled (for OTP bypass)
CREATE OR REPLACE FUNCTION public.is_demo_mode()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT true; -- Always return true for demo environment
$$;

-- Function to validate demo OTP (always accepts 000000)
CREATE OR REPLACE FUNCTION public.validate_demo_otp(phone_number TEXT, otp_code TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT CASE 
    WHEN phone_number IN ('+919991199911', '+919992299922', '+919993399933', '+919994499944') 
         AND otp_code = '000000' 
    THEN true
    ELSE false
END;
$$;

-- Function to get sample demo user data for login screen display
CREATE OR REPLACE FUNCTION public.get_sample_rows()
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT jsonb_build_object(
    'demo_credentials', jsonb_build_array(
        jsonb_build_object(
            'role', 'Patient',
            'email', 'patient@ayursutra.com',
            'password', 'Demo@1234',
            'mobile', '9991199911',
            'abha', 'demo.patient@abdm',
            'otp', '000000'
        ),
        jsonb_build_object(
            'role', 'Doctor',
            'email', 'doctor@ayursutra.com',
            'password', 'Demo@1234',
            'mobile', '9992299922',
            'abha', 'demo.doctor@abdm',
            'otp', '000000'
        ),
        jsonb_build_object(
            'role', 'Chemist',
            'email', 'chemist@ayursutra.com',
            'password', 'Demo@1234',
            'mobile', '9993399933',
            'abha', 'demo.chemist@abdm',
            'otp', '000000'
        )
    )
);
$$;