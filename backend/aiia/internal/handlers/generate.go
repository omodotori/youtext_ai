package handlers

import (
	"net/http"

	"aiia/internal/services"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

type requestBody struct {
	URL  string `json:"url" binding:"required,url"`
	Type string `json:"type" binding:"required"`
}

func MakeGenerateHandler(svc *services.Service, log *logrus.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req requestBody
		if err := c.ShouldBindJSON(&req); err != nil {
			log.Warnf("bad request: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request body"})
			return
		}

		log.Infof("Processing URL=%s, type=%s", req.URL, req.Type)

		res, err := svc.Process(req.URL, req.Type)
		if err != nil {
			log.Errorf("processing error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusOK, res)
	}
}
