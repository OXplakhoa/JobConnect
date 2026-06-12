-- Add a dedicated "hired/accepted" notification message to the status-update RPC.
-- The recruiter can now move an application interview → accepted (Tuyển); without
-- this the seeker received the generic "đã được cập nhật" body. Only the CASE
-- branch changes; all other behaviour is identical to 20260530000000.
CREATE OR REPLACE FUNCTION update_application_with_note(
  p_application_id UUID,
  p_status TEXT,
  p_note TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_recruiter_id UUID := auth.uid();
  v_note_id UUID;
  v_updated_id UUID;
  v_seeker_id UUID;
  v_job_title TEXT;
  v_previous_status TEXT;
BEGIN
  IF v_recruiter_id IS NULL THEN
    RAISE EXCEPTION 'Unauthenticated';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM applications a
    WHERE a.id = p_application_id
      AND a.job_id = ANY(ARRAY(SELECT get_recruiter_job_ids()))
  ) THEN
    RAISE EXCEPTION 'Bạn không có quyền cập nhật Application này';
  END IF;

  SELECT a.seeker_id, j.title, a.status
  INTO v_seeker_id, v_job_title, v_previous_status
  FROM applications a
  JOIN job_posts j ON j.id = a.job_id
  WHERE a.id = p_application_id;

  UPDATE applications
  SET status = p_status,
      updated_at = now()
  WHERE id = p_application_id
  RETURNING id INTO v_updated_id;

  IF v_updated_id IS NULL THEN
    RAISE EXCEPTION 'Không thể cập nhật trạng thái Application';
  END IF;

  IF p_status IS DISTINCT FROM v_previous_status THEN
    INSERT INTO notifications (user_id, type, title, body, data_json)
    VALUES (
      v_seeker_id,
      'application_status',
      'Cập nhật đơn ứng tuyển',
      CASE p_status
        WHEN 'reviewing' THEN 'Recruiter đang xem xét hồ sơ của bạn cho "' || v_job_title || '".'
        WHEN 'rejected' THEN 'Application cho "' || v_job_title || '" đã bị từ chối.'
        WHEN 'interview' THEN 'Bạn đã được mời phỏng vấn cho "' || v_job_title || '".'
        WHEN 'accepted' THEN 'Chúc mừng! Bạn đã được tuyển cho "' || v_job_title || '".'
        ELSE 'Application của bạn cho "' || v_job_title || '" đã được cập nhật.'
      END,
      jsonb_build_object('application_id', p_application_id, 'status', p_status)
    );
  END IF;

  IF btrim(coalesce(p_note, '')) = '' THEN
    RETURN;
  END IF;

  SELECT id
  INTO v_note_id
  FROM application_notes
  WHERE application_id = p_application_id
    AND recruiter_id = v_recruiter_id
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_note_id IS NULL THEN
    INSERT INTO application_notes (application_id, recruiter_id, note)
    VALUES (p_application_id, v_recruiter_id, p_note);
  ELSE
    UPDATE application_notes
    SET note = p_note
    WHERE id = v_note_id;
  END IF;
END;
$$;
