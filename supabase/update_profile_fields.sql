-- Migration: Add profile fields to users table
-- Path: supabase/update_profile_fields.sql

ALTER TABLE public.users ADD COLUMN IF NOT EXISTS nickname VARCHAR(100);
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS date_of_birth DATE;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS relationship_status VARCHAR(20) CHECK (relationship_status IN ('Dating', 'Married'));
