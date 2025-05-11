import React, { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import { fetchVideoById } from "../services/api";
import VideoPlayer from "../components/VideoPlayer";
import Header from "../components/Header";


const VideoPage = () => {
  const { id } = useParams();
  const [video, setVideo] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const getVideo = async () => {
      try {
        const data = await fetchVideoById(id);
        setVideo(data);
        setLoading(false);
      } catch (err) {
        setError("Không thể tải video");
        setLoading(false);
      }
    };

    getVideo();
  }, [id]);

  if (loading) return <div className="loading">Đang tải...</div>;
  if (error) return <div className="error">{error}</div>;
  if (!video) return <div className="not-found">Không tìm thấy video</div>;

  return (
    <div>
      <Header />
      <div className="video-page-container">
        <Link to="/" className="back-button">← Quay lại danh sách</Link>
        
        <div className="video-page-header">
          <h1 className="video-title-large">{video.title}</h1>
        </div>
        
        <VideoPlayer src={video.video_url} />
        
        <div className="video-actions">
          <button className="action-button">
            <i className="far fa-thumbs-up"></i> Thích
          </button>
          <button className="action-button">
            <i className="far fa-share-square"></i> Chia sẻ
          </button>
          <button className="action-button">
            <i className="far fa-bookmark"></i> Lưu
          </button>
        </div>
        
        <div className="video-info">
          <p className="video-description">{video.description}</p>
          <p className="video-meta">Đăng tải: {new Date(video.uploadDate).toLocaleDateString('vi-VN')}</p>
          <p className="video-meta">Lượt xem: {formatViewCount(video.views || 0)}</p>
        </div>
      </div>
    </div>
  );
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

export default VideoPage;