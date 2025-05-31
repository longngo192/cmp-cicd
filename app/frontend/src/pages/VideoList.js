import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import Video from "../components/Video";
import Header from "../components/Header";
import { fetchVideos } from "../services/api";


const VideoList = () => {
  const [videos, setVideos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const getVideos = async () => {
      try {
        const data = await fetchVideos();
        setVideos(data);
        setLoading(false);
      } catch (err) {
        setError("Không thể tải danh sách video");
        setLoading(false);
      }
    };

    getVideos();
  }, []);

  if (loading) return <div className="loading">Đang tải...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div>
      <h1>v2</h1>  
      <Header />
      <div className="video-list-container">
        <h1>Video Mới Đăng</h1>
        <div className="video-grid">
          {videos.map((video) => (
            <Link to={`/videos/${video.id}`} key={video.id} className="video-link">
              <Video video={video} />
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
};

export default VideoList;