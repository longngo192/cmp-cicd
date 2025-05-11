import React from "react";

const Task = ({ task, onUpdate, onDelete }) => {
    return (
        <div className="task">
            <h3>{task.title}</h3>
            <p>{task.description}</p>
            <p>Status: {task.completed ? "✅ Completed" : "❌ Pending"}</p>
            <button onClick={() => onUpdate(task.id, { completed: !task.completed })}>
                {task.completed ? "Mark as Incomplete" : "Mark as Complete"}
            </button>
            <button onClick={() => onDelete(task.id)}>Delete</button>
        </div>
    );
};

export default Task;
