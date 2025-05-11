// src/components/Video.js
import React from "react";

const Video = ({ video }) => {
  return (
    <div className="video-card">
      <div className="thumbnail-container">
        <img src={video.thumbnailUrl} alt={video.title} className="thumbnail" />
        <span className="duration">{formatDuration(video.duration)}</span>
      </div>
      <div className="video-info">
        <h3 className="video-title">{video.title}</h3>
        <p className="upload-date">
          {new Date(video.uploadDate).toLocaleDateString('vi-VN')}
        </p>
        <div className="video-stats">
          <span className="video-stat">
            <i className="far fa-eye"></i> {formatViewCount(video.views || 0)}
          </span>
          <span className="video-stat">
            <i className="far fa-thumbs-up"></i> {formatLikeCount(video.likes || 0)}
          </span>
        </div>
      </div>
    </div>
  );
};

// Hàm chuyển đổi thời lượng từ giây sang định dạng mm:ss
const formatDuration = (seconds) => {
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes}:${remainingSeconds < 10 ? '0' : ''}${remainingSeconds}`;
};

// Hàm format số lượng view
const formatViewCount = (count) => {
  if (count >= 1000000) {
    return (count / 1000000).toFixed(1) + 'M';
  } else if (count >= 1000) {
    return (count / 1000).toFixed(1) + 'K';
  }
  return count;
};

// Hàm format số lượng like
const formatLikeCount = (count) => {
  if (count >= 1000000) {
    return (count / 1000000).toFixed(1) + 'M';
  } else if (count >= 1000) {
    return (count / 1000).toFixed(1) + 'K';
  }
  return count;
};

export default Video;

