package repository

import (
	"context"
	"database/sql"
	"history/internal/models"
)

type HistoryRepository interface {
	Save(ctx context.Context, h *models.History) error
	FindAll(ctx context.Context) ([]models.History, error)
	FindByUserID(ctx context.Context, userID int) ([]models.HistoryResponse, error)
	DeleteByUserID(ctx context.Context, userID int) error
	CountByUserID(ctx context.Context, userID int) (int64, error)
	DeleteByID(ctx context.Context, id int64) (bool, error)
}

type historyRepo struct {
	db *sql.DB
}

func NewHistoryRepository(db *sql.DB) HistoryRepository {
	return &historyRepo{db: db}
}

func (r *historyRepo) Save(ctx context.Context, h *models.History) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}

	defer tx.Rollback()

	query := `INSERT INTO history (user_id, video_title, link, summary, transcript) 
	          VALUES ($1, $2, $3, $4, $5) RETURNING id, created_at`
	err = tx.QueryRowContext(ctx, query, h.UserID, h.VideoTitle, h.Link, h.Summary, h.Transcript).
		Scan(&h.ID, &h.CreatedAt)
	if err != nil {
		return err
	}

	if len(h.Highlights) > 0 {
		stmt, err := tx.PrepareContext(ctx, `INSERT INTO highlights (history_id, highlight) VALUES ($1, $2) RETURNING id`)
		if err != nil {
			return err
		}
		defer stmt.Close()

		for i := range h.Highlights {
			h.Highlights[i].HistoryID = h.ID
			err = stmt.QueryRowContext(ctx, h.ID, h.Highlights[i].Highlight).Scan(&h.Highlights[i].ID)
			if err != nil {
				return err
			}
		}
	}

	if len(h.Timecodes) > 0 {
		stmt, err := tx.PrepareContext(ctx, `INSERT INTO timecodes (history_id, timecode, descriptions) VALUES ($1, $2, $3) RETURNING id`)
		if err != nil {
			return err
		}
		defer stmt.Close()

		for i := range h.Timecodes {
			h.Timecodes[i].HistoryID = h.ID
			err = stmt.QueryRowContext(ctx, h.ID, h.Timecodes[i].Timecode, h.Timecodes[i].Descriptions).Scan(&h.Timecodes[i].ID)
			if err != nil {
				return err
			}
		}
	}

	return tx.Commit()
}

func (r *historyRepo) FindAll(ctx context.Context) ([]models.History, error) {
	rows, err := r.db.QueryContext(ctx, "SELECT id, user_id, video_title, link, created_at, summary, transcript FROM history")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var histories []models.History
	for rows.Next() {
		var h models.History
		if err := rows.Scan(&h.ID, &h.UserID, &h.VideoTitle, &h.Link, &h.CreatedAt, &h.Summary, &h.Transcript); err != nil {
			return nil, err
		}
		histories = append(histories, h)
	}
	return histories, nil
}

func (r *historyRepo) FindByUserID(ctx context.Context, userID int) ([]models.HistoryResponse, error) {
	rows, err := r.db.QueryContext(ctx, "SELECT id, user_id, video_title, link, created_at, summary, transcript FROM history WHERE user_id = $1", userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var histories []models.HistoryResponse
	for rows.Next() {
		var h models.HistoryResponse
		if err := rows.Scan(&h.ID, &h.UserID, &h.VideoTitle, &h.Link, &h.CreatedAt, &h.Summary, &h.Transcript); err != nil {
			return nil, err
		}

		if err := r.loadRelations(ctx, &h); err != nil {
			return nil, err
		}

		histories = append(histories, h)
	}

	if histories == nil {
		histories = []models.HistoryResponse{}
	}

	return histories, nil
}

func (r *historyRepo) DeleteByUserID(ctx context.Context, userID int) error {
	_, err := r.db.ExecContext(ctx, "DELETE FROM history WHERE user_id = $1", userID)
	return err
}

func (r *historyRepo) CountByUserID(ctx context.Context, userID int) (int64, error) {
	var count int64
	err := r.db.QueryRowContext(ctx, "SELECT COUNT(*) FROM history WHERE user_id = $1", userID).Scan(&count)
	return count, err
}

func (r *historyRepo) DeleteByID(ctx context.Context, id int64) (bool, error) {
	res, err := r.db.ExecContext(ctx, "DELETE FROM history WHERE id = $1", id)
	if err != nil {
		return false, err
	}
	rowsAffected, _ := res.RowsAffected()
	return rowsAffected > 0, nil
}

func (r *historyRepo) loadRelations(ctx context.Context, h *models.HistoryResponse) error {
	hlRows, err := r.db.QueryContext(ctx, "SELECT highlight FROM highlights WHERE history_id = $1", h.ID)
	if err != nil {
		return err
	}
	defer hlRows.Close()

	for hlRows.Next() {
		var hl models.Highlight
		if err := hlRows.Scan(&hl.Highlight); err != nil {
			return err
		}
		hl.HistoryID = h.ID
		h.Highlights = append(h.Highlights, hl.Highlight)
	}

	tcRows, err := r.db.QueryContext(ctx, "SELECT id, timecode, descriptions FROM timecodes WHERE history_id = $1", h.ID)
	if err != nil {
		return err
	}
	defer tcRows.Close()

	for tcRows.Next() {
		var tc models.Timecode
		if err := tcRows.Scan(&tc.ID, &tc.Timecode, &tc.Descriptions); err != nil {
			return err
		}
		tc.HistoryID = h.ID
		h.Timecodes = append(h.Timecodes, tc)
	}

	return nil
}
