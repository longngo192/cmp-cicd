import axios from 'axios';

// Get the API base URL from environment variables
const API_URL = process.env.REACT_APP_API_URL || 'https://cmp.realworld-cicd-labs.ngosylong.com'; // Fallback for safety

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Get all videos
export const fetchVideos = async () => {
  try {
    const response = await api.get('/videos');
    return response.data;
  } catch (error) {
    throw new Error(error.response?.data?.error || 'Failed to fetch videos');
  }
};

// Get a single video by ID
export const fetchVideoById = async (videoId) => {
  try {
    const response = await api.get(`/videos/${videoId}`);
    return response.data;
  } catch (error) {
    throw new Error(error.response?.data?.error || 'Failed to fetch video');
  }
};

// Create a new video
export const createVideo = async (videoData) => {
  try {
    const response = await api.post('/videos', videoData);
    return response.data;
  } catch (error) {
    throw new Error(error.response?.data?.error || 'Failed to create video');
  }
};

// Update a video
export const updateVideo = async (videoId, videoData) => {
  try {
    const response = await api.put(`/videos/${videoId}`, videoData);
    return response.data;
  } catch (error) {
    throw new Error(error.response?.data?.error || 'Failed to update video');
  }
};

// Delete a video
export const deleteVideo = async (videoId) => {
  try {
    const response = await api.delete(`/videos/${videoId}`);
    return response.data;
  } catch (error) {
    throw new Error(error.response?.data?.error || 'Failed to delete video');
  }
};