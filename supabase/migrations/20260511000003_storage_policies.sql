-- ============================================================
-- STORAGE RLS POLICIES
-- ============================================================

-- public-assets: anyone can read, owner can write
-- Path pattern: {type}/{userId}/{filename}
-- (storage.foldername(name))[2] extracts the userId segment

CREATE POLICY "public_assets_select"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'public-assets');

CREATE POLICY "public_assets_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'public-assets'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );

CREATE POLICY "public_assets_update"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'public-assets'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );

CREATE POLICY "public_assets_delete"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'public-assets'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );

-- private-files: owner only (all operations)
CREATE POLICY "private_files_all"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'private-files'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );
