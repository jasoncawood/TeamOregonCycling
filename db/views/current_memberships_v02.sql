/* Updating to include the amount_paid_* columns */
SELECT m.*
  FROM (
    SELECT m.*, row_number()
      OVER (PARTITION BY user_id ORDER BY ends_on DESC) seqnum
      FROM memberships m WHERE starts_on <= CURRENT_DATE
  ) m
  WHERE seqnum = 1
