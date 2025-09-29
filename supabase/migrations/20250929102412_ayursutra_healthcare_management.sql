-- Location: supabase/migrations/20250929102412_ayursutra_healthcare_management.sql
-- Schema Analysis: Fresh project - no existing schema
-- Integration Type: Complete Healthcare Management System
-- Dependencies: None (fresh implementation)

-- 1. Types and Enums
CREATE TYPE public.user_role AS ENUM ('patient', 'doctor', 'chemist', 'admin', 'guest');
CREATE TYPE public.therapy_type AS ENUM ('vamana', 'virechana', 'basti', 'nasya', 'raktamokshana', 'abhyanga', 'shirodhara', 'pizhichil', 'udvartana');
CREATE TYPE public.session_status AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled', 'rescheduled');
CREATE TYPE public.payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded', 'partially_refunded');
CREATE TYPE public.therapy_phase AS ENUM ('purva_karma', 'pradhana_karma', 'paschat_karma');
CREATE TYPE public.notification_type AS ENUM ('appointment', 'payment', 'progress', 'care_instruction', 'emergency', 'system');
CREATE TYPE public.gender AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');
CREATE TYPE public.appointment_type AS ENUM ('consultation', 'therapy', 'follow_up', 'emergency');
CREATE TYPE public.inventory_status AS ENUM ('in_stock', 'low_stock', 'out_of_stock', 'expired', 'recalled');
CREATE TYPE public.prescription_status AS ENUM ('prescribed', 'dispensed', 'completed', 'cancelled');

-- 2. Core User Management Tables
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    date_of_birth DATE,
    gender public.gender,
    role public.user_role DEFAULT 'patient'::public.user_role,
    is_active BOOLEAN DEFAULT true,
    abha_id TEXT UNIQUE,
    abha_address TEXT,
    language_preference TEXT DEFAULT 'en',
    profile_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ABHA verification and consent logs
CREATE TABLE public.abha_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    abha_id TEXT NOT NULL,
    verification_token TEXT,
    otp_sent_at TIMESTAMPTZ,
    verified_at TIMESTAMPTZ,
    consent_given_at TIMESTAMPTZ,
    consent_revoked_at TIMESTAMPTZ,
    verification_status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Patient-specific information
CREATE TABLE public.patient_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    medical_history JSONB DEFAULT '{}',
    allergies TEXT[],
    current_medications JSONB DEFAULT '[]',
    constitution_type TEXT, -- Vata, Pitta, Kapha
    body_weight DECIMAL(5,2),
    height DECIMAL(5,2),
    blood_pressure TEXT,
    pulse_rate INTEGER,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Doctor-specific information
CREATE TABLE public.doctor_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    license_number TEXT NOT NULL UNIQUE,
    specialization TEXT[],
    years_of_experience INTEGER,
    qualification TEXT,
    hpr_id TEXT UNIQUE, -- Health Professional Registry ID
    hpr_verified_at TIMESTAMPTZ,
    license_expiry_date DATE,
    consultation_fee DECIMAL(10,2),
    is_verified BOOLEAN DEFAULT false,
    verification_documents JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Chemist/Pharmacy information
CREATE TABLE public.chemist_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    pharmacy_name TEXT NOT NULL,
    license_number TEXT NOT NULL UNIQUE,
    license_expiry_date DATE,
    address JSONB NOT NULL,
    is_verified BOOLEAN DEFAULT false,
    verification_documents JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Healthcare Centers and Locations
CREATE TABLE public.healthcare_centers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address JSONB NOT NULL,
    phone_number TEXT,
    email TEXT,
    license_number TEXT,
    is_verified BOOLEAN DEFAULT false,
    operating_hours JSONB DEFAULT '{}',
    location POINT, -- PostGIS point for geographic location
    services_offered TEXT[],
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Therapy rooms and resources
CREATE TABLE public.therapy_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    center_id UUID REFERENCES public.healthcare_centers(id) ON DELETE CASCADE,
    room_number TEXT NOT NULL,
    room_type TEXT,
    capacity INTEGER DEFAULT 1,
    amenities TEXT[],
    is_active BOOLEAN DEFAULT true,
    equipment JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Therapy and Treatment Management
CREATE TABLE public.therapy_packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    therapy_types public.therapy_type[],
    duration_days INTEGER,
    total_sessions INTEGER,
    price DECIMAL(10,2),
    contraindications TEXT[],
    eligibility_criteria JSONB DEFAULT '{}',
    sop_documents JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Individual therapy sessions
CREATE TABLE public.therapy_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    therapist_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    package_id UUID REFERENCES public.therapy_packages(id) ON DELETE SET NULL,
    room_id UUID REFERENCES public.therapy_rooms(id) ON DELETE SET NULL,
    therapy_type public.therapy_type NOT NULL,
    therapy_phase public.therapy_phase DEFAULT 'pradhana_karma',
    session_number INTEGER,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    duration_minutes INTEGER DEFAULT 90,
    status public.session_status DEFAULT 'scheduled',
    session_notes JSONB DEFAULT '{}',
    vital_signs JSONB DEFAULT '{}',
    contraindications_checked BOOLEAN DEFAULT false,
    complications JSONB DEFAULT '{}',
    progress_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Live session tracking
CREATE TABLE public.live_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES public.therapy_sessions(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    milestones JSONB DEFAULT '[]',
    emergency_alerts JSONB DEFAULT '[]',
    real_time_notes TEXT,
    vitals_monitoring JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Scheduling and Appointments
CREATE TABLE public.appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    center_id UUID REFERENCES public.healthcare_centers(id) ON DELETE CASCADE,
    appointment_type public.appointment_type DEFAULT 'consultation',
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    status public.session_status DEFAULT 'scheduled',
    chief_complaint TEXT,
    consultation_fee DECIMAL(10,2),
    notes TEXT,
    is_teleconsultation BOOLEAN DEFAULT false,
    meeting_link TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Inventory and Medicine Management
CREATE TABLE public.medicine_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chemist_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    medicine_name TEXT NOT NULL,
    generic_name TEXT,
    manufacturer TEXT,
    batch_number TEXT,
    expiry_date DATE,
    quantity_available INTEGER DEFAULT 0,
    price_per_unit DECIMAL(10,2),
    status public.inventory_status DEFAULT 'in_stock',
    medicine_type TEXT,
    dosage_form TEXT,
    strength TEXT,
    storage_conditions TEXT,
    hsn_code TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Oil and herbal inventory
CREATE TABLE public.therapy_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    center_id UUID REFERENCES public.healthcare_centers(id) ON DELETE CASCADE,
    item_name TEXT NOT NULL,
    item_type TEXT, -- oil, herb, equipment
    batch_number TEXT,
    expiry_date DATE,
    quantity_available DECIMAL(10,2),
    unit_of_measure TEXT,
    supplier_name TEXT,
    cost_per_unit DECIMAL(10,2),
    storage_location TEXT,
    status public.inventory_status DEFAULT 'in_stock',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Prescriptions and Medicine Orders
CREATE TABLE public.prescriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.therapy_sessions(id) ON DELETE SET NULL,
    prescription_date DATE DEFAULT CURRENT_DATE,
    status public.prescription_status DEFAULT 'prescribed',
    pathya_apathya JSONB DEFAULT '{}',
    lifestyle_recommendations TEXT,
    follow_up_date DATE,
    is_fhir_compliant BOOLEAN DEFAULT false,
    fhir_resource_id TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.prescription_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prescription_id UUID REFERENCES public.prescriptions(id) ON DELETE CASCADE,
    medicine_id UUID REFERENCES public.medicine_inventory(id) ON DELETE SET NULL,
    medicine_name TEXT NOT NULL,
    dosage TEXT,
    frequency TEXT,
    duration TEXT,
    quantity_prescribed INTEGER,
    quantity_dispensed INTEGER DEFAULT 0,
    instructions TEXT,
    substitution_allowed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 8. Payment and Billing
CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.therapy_sessions(id) ON DELETE SET NULL,
    appointment_id UUID REFERENCES public.appointments(id) ON DELETE SET NULL,
    prescription_id UUID REFERENCES public.prescriptions(id) ON DELETE SET NULL,
    amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    final_amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'INR',
    payment_method TEXT,
    payment_gateway_id TEXT,
    transaction_id TEXT,
    status public.payment_status DEFAULT 'pending',
    payment_date TIMESTAMPTZ,
    refund_amount DECIMAL(10,2) DEFAULT 0.00,
    invoice_number TEXT,
    gstin TEXT,
    hsn_sac_code TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 9. Notifications and Communications
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    type public.notification_type DEFAULT 'system',
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    template_id TEXT,
    language TEXT DEFAULT 'en',
    delivery_channels TEXT[] DEFAULT ARRAY['in_app'],
    sms_sent_at TIMESTAMPTZ,
    email_sent_at TIMESTAMPTZ,
    push_sent_at TIMESTAMPTZ,
    is_read BOOLEAN DEFAULT false,
    scheduled_for TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- DLT compliance for SMS
CREATE TABLE public.sms_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id TEXT NOT NULL UNIQUE,
    template_content TEXT NOT NULL,
    category TEXT,
    language TEXT DEFAULT 'en',
    dlt_approved BOOLEAN DEFAULT false,
    sender_id TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 10. Audit and Compliance
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    resource_type TEXT,
    resource_id UUID,
    old_values JSONB DEFAULT '{}',
    new_values JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    session_id TEXT,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- FHIR compliance tracking
CREATE TABLE public.fhir_resources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    local_resource_id UUID NOT NULL,
    resource_type TEXT NOT NULL,
    fhir_id TEXT NOT NULL,
    fhir_version TEXT DEFAULT 'R4',
    resource_data JSONB NOT NULL,
    last_sync_at TIMESTAMPTZ,
    sync_status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 11. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_abha_id ON public.user_profiles(abha_id);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_therapy_sessions_patient_id ON public.therapy_sessions(patient_id);
CREATE INDEX idx_therapy_sessions_doctor_id ON public.therapy_sessions(doctor_id);
CREATE INDEX idx_therapy_sessions_scheduled_date ON public.therapy_sessions(scheduled_date);
CREATE INDEX idx_therapy_sessions_status ON public.therapy_sessions(status);
CREATE INDEX idx_appointments_patient_id ON public.appointments(patient_id);
CREATE INDEX idx_appointments_doctor_id ON public.appointments(doctor_id);
CREATE INDEX idx_appointments_date ON public.appointments(appointment_date);
CREATE INDEX idx_payments_patient_id ON public.payments(patient_id);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX idx_medicine_inventory_chemist_id ON public.medicine_inventory(chemist_id);
CREATE INDEX idx_medicine_inventory_expiry_date ON public.medicine_inventory(expiry_date);
CREATE INDEX idx_audit_logs_user_id ON public.audit_logs(user_id);
CREATE INDEX idx_audit_logs_timestamp ON public.audit_logs(timestamp);

-- 12. Functions (BEFORE RLS policies)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role, abha_id)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'patient'::public.user_role),
    NEW.raw_user_meta_data->>'abha_id'
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.is_doctor()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'doctor' AND up.is_active = true
)
$$;

CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_patient_data(patient_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    -- User can access their own data
    SELECT 1 WHERE auth.uid() = patient_uuid
    UNION
    -- Doctors can access their patients' data through appointments/sessions
    SELECT 1 FROM public.user_profiles up
    JOIN public.therapy_sessions ts ON ts.doctor_id = up.id
    WHERE up.id = auth.uid() AND ts.patient_id = patient_uuid AND up.role = 'doctor'
    UNION
    -- Admin can access all patient data
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() AND au.raw_user_meta_data->>'role' = 'admin'
)
$$;

-- 13. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.abha_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.patient_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chemist_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.healthcare_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.therapy_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.therapy_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.therapy_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medicine_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.therapy_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescription_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sms_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fhir_resources ENABLE ROW LEVEL SECURITY;

-- 14. RLS Policies
-- Pattern 1: Core user table (user_profiles)
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership
CREATE POLICY "users_manage_own_abha_verifications"
ON public.abha_verifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_patient_profiles"
ON public.patient_profiles
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_doctor_profiles"
ON public.doctor_profiles
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_chemist_profiles"
ON public.chemist_profiles
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read, private write for healthcare centers
CREATE POLICY "public_can_read_healthcare_centers"
ON public.healthcare_centers
FOR SELECT
TO public
USING (true);

CREATE POLICY "admin_manage_healthcare_centers"
ON public.healthcare_centers
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Public read for therapy packages
CREATE POLICY "public_can_read_therapy_packages"
ON public.therapy_packages
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "admin_manage_therapy_packages"
ON public.therapy_packages
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Complex patient data access
CREATE POLICY "patient_data_access_therapy_sessions"
ON public.therapy_sessions
FOR ALL
TO authenticated
USING (public.can_access_patient_data(patient_id))
WITH CHECK (patient_id = auth.uid());

CREATE POLICY "patient_data_access_appointments"
ON public.appointments
FOR ALL
TO authenticated
USING (public.can_access_patient_data(patient_id))
WITH CHECK (patient_id = auth.uid());

CREATE POLICY "patient_data_access_prescriptions"
ON public.prescriptions
FOR ALL
TO authenticated
USING (public.can_access_patient_data(patient_id))
WITH CHECK (patient_id = auth.uid());

-- Inventory management (role-based)
CREATE POLICY "chemists_manage_medicine_inventory"
ON public.medicine_inventory
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() 
        AND (up.role = 'chemist' AND chemist_id = auth.uid()) 
        OR up.role = 'admin'
    )
)
WITH CHECK (chemist_id = auth.uid());

-- Notifications
CREATE POLICY "users_manage_own_notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Payments
CREATE POLICY "users_manage_own_payments"
ON public.payments
FOR ALL
TO authenticated
USING (patient_id = auth.uid())
WITH CHECK (patient_id = auth.uid());

-- Admin access to audit logs
CREATE POLICY "admin_access_audit_logs"
ON public.audit_logs
FOR SELECT
TO authenticated
USING (public.is_admin_from_auth());

-- 15. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_patient_profiles_updated_at
  BEFORE UPDATE ON public.patient_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_doctor_profiles_updated_at
  BEFORE UPDATE ON public.doctor_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 16. Mock Data with Complete Auth Users
DO $$
DECLARE
    patient_uuid UUID := gen_random_uuid();
    doctor_uuid UUID := gen_random_uuid();
    chemist_uuid UUID := gen_random_uuid();
    admin_uuid UUID := gen_random_uuid();
    center_id UUID := gen_random_uuid();
    package_id UUID := gen_random_uuid();
    appointment_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields matching mock credentials from authentication screen
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (patient_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'patient@ayursutra.com', crypt('patient123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Priya Sharma", "role": "patient", "abha_id": "12345678901234"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, '+919876543210', '', '', null),
        
        (doctor_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'doctor@ayursutra.com', crypt('doctor123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Dr. Rajesh Kumar", "role": "doctor", "abha_id": "98765432109876"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, '+919876543211', '', '', null),
         
        (chemist_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'chemist@ayursutra.com', crypt('chemist123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Ramesh Medicorp", "role": "chemist", "abha_id": "11223344556677"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, '+919876543212', '', '', null),
         
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@ayursutra.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, '+919876543213', '', '', null);

    -- Patient profile details
    INSERT INTO public.patient_profiles (user_id, emergency_contact_name, emergency_contact_phone, constitution_type, body_weight, height)
    VALUES (patient_uuid, 'Anita Sharma', '+919876543220', 'Vata-Pitta', 65.5, 165.0);

    -- Doctor profile details
    INSERT INTO public.doctor_profiles (user_id, license_number, specialization, years_of_experience, qualification, is_verified, consultation_fee)
    VALUES (doctor_uuid, 'AYUR-KAR-2024-001', ARRAY['Panchakarma', 'General Ayurveda'], 15, 'BAMS, MD (Panchakarma)', true, 2000.00);

    -- Chemist profile details
    INSERT INTO public.chemist_profiles (user_id, pharmacy_name, license_number, address, is_verified)
    VALUES (chemist_uuid, 'Ayur Medicorp', 'CHEM-KAR-2024-001', '{"street": "MG Road", "city": "Kochi", "state": "Kerala", "pincode": "682001"}'::jsonb, true);

    -- Healthcare center
    INSERT INTO public.healthcare_centers (id, name, address, phone_number, email, is_verified, services_offered)
    VALUES (center_id, 'AyurSutra Wellness Center', 
           '{"street": "Marine Drive", "city": "Kochi", "state": "Kerala", "pincode": "682031"}'::jsonb,
           '+914842345678', 'info@ayursutra.com', true, 
           ARRAY['panchakarma', 'consultation', 'ayurvedic_medicines']);

    -- Therapy package
    INSERT INTO public.therapy_packages (id, name, description, therapy_types, duration_days, total_sessions, price)
    VALUES (package_id, 'Complete Panchakarma Package', 'Comprehensive 21-day Panchakarma treatment',
           ARRAY['abhyanga', 'shirodhara', 'basti']::public.therapy_type[], 21, 21, 75000.00);

    -- Sample therapy session
    INSERT INTO public.therapy_sessions (patient_id, doctor_id, package_id, therapy_type, scheduled_date, scheduled_time, session_number)
    VALUES (patient_uuid, doctor_uuid, package_id, 'abhyanga', '2025-09-30', '10:00:00', 9);

    -- Sample appointment
    INSERT INTO public.appointments (id, patient_id, doctor_id, center_id, appointment_date, appointment_time, chief_complaint, consultation_fee)
    VALUES (appointment_id, patient_uuid, doctor_uuid, center_id, '2025-09-30', '14:00:00', 
           'Follow-up consultation for ongoing Panchakarma treatment', 2000.00);

    -- Sample medicine inventory
    INSERT INTO public.medicine_inventory (chemist_id, medicine_name, generic_name, quantity_available, price_per_unit, medicine_type)
    VALUES (chemist_uuid, 'Triphala Churna', 'Triphala Powder', 50, 250.00, 'Ayurvedic Medicine'),
           (chemist_uuid, 'Brahmi Ghrita', 'Brahmi Medicated Ghee', 25, 450.00, 'Medicated Oil');

    -- Sample notifications
    INSERT INTO public.notifications (user_id, type, title, message)
    VALUES (patient_uuid, 'care_instruction', 'Pre-session Preparation', 
           'Please avoid heavy meals 2 hours before your Abhyanga session tomorrow at 10:00 AM'),
           (patient_uuid, 'progress', 'Progress Milestone', 
           'Congratulations! You have completed 8 out of 21 sessions in your treatment plan');

    -- Sample payment
    INSERT INTO public.payments (patient_id, session_id, amount, tax_amount, final_amount, status, invoice_number)
    VALUES (patient_uuid, (SELECT id FROM public.therapy_sessions LIMIT 1), 3500.00, 630.00, 4130.00, 'completed', 'INV-2024-001');

END $$;