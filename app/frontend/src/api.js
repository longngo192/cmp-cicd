const API_URL = process.env.REACT_APP_API_URL || "http://localhost:5000";export const getVideos = async () => {
    const response = await fetch(`${API_URL}/videos`);
    return response.json();
};

export const getVideo = async (id) => {
    const response = await fetch(`${API_URL}/videos/${id}`);
    return response.json();
};

// Fetch all tasks v1
export const getTasks = async () => {
    const response = await fetch(`${API_URL}/tasks`);
    return response.json();
};

// Create a new task
export const createTask = async (task) => {
    const response = await fetch(`${API_URL}/tasks`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(task),
    });
    return response.json();
};

// Update a task
export const updateTask = async (taskId, updatedTask) => {
    const response = await fetch(`${API_URL}/tasks/${taskId}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(updatedTask),
    });
    return response.json();
};

// Delete a task
export const deleteTask = async (taskId) => {
    const response = await fetch(`${API_URL}/tasks/${taskId}`, {
        method: "DELETE",
    });
    return response.json();
};
