const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const ip = require('ip');

const port = 8080;
const app = express();
const server = http.createServer(app);
const io = socketIo(server);

server.listen(port, () => {
    console.log('Socket.IO server started.');
    console.log('IP Address:', ip.address());
    console.log('Port:', port);
});

// Map to store Socket.IO connections with their IDs
const clients = new Map();
const callers = new Map();

io.on('connection', (socket) => {
    console.log('New client connected:', socket.id);

    // Handle incoming authentication message
    socket.once('authentication', (data) => {
        try {
            const { userId } = data;
            if (!userId) {
                socket.disconnect();
                console.log('Connection closed: No user ID provided.');
                return;
            }
            if (clients.has(userId)) {
                console.log(`Connection closed: User ID '${userId}' is already in use.`);
                socket.disconnect();
                return;
            }
            // Save the Socket.IO connection with the provided user ID
            clients.set(userId, socket);
            console.log(`User '${userId}' authenticated and connected.`);
        } catch (error) {
            socket.disconnect();
            console.error('Error handling authentication message:', error);
        }
    });

    // Handle disconnection
    socket.on('disconnect', () => {
        // Remove the Socket.IO connection from the clients map
        for (const [userId, client] of clients) {
            if (client === socket) {
                clients.delete(userId);
                console.log(`User '${userId}' disconnected.`);
                break;
            }
        }
    });

    // Handle errors
    socket.on('error', (error) => {
        console.error('Socket.IO error:', error);
    });

    // Handle incoming messages
    socket.on('message', (message) => {
        // Your message handling logic here
        console.log('Message received:', message);
    });

    // Handle call initiation
    socket.on('call', (data) => {
        // Your call initiation logic here
        console.log('Call initiated:', data);
        handleCall(data.from, data.to);
    });

    // Handle call acceptance
    socket.on('call_accept', (data) => {
        // Your call acceptance logic here
        console.log('Call accepted:', data);
        const { from, to } = data;
        if (clients.has(from) && clients.has(to)) {
            callers.set(from, socket);
            callers.set(to, socket);
            console.log(`User IDs '${from}' and '${to}' saved for video call.`);
            const recipient = clients.get(to);
            recipient.emit('call_accepted');
        } else {
            console.log(`User IDs '${from}' and '${to}' are not both connected.`);
        }
    });

    // Handle call ended
    socket.on('call_ended', (data) => {
        // Your call ended logic here
        console.log('Call ended:', data);
        const callerID = data.callerID;
        if (clients.has(callerID)) {
            const recipient = clients.get(callerID);
            console.log(`Sending call ending message to user ID: ${callerID}`);
            recipient.emit('call_ended');
        } else {
            console.log('Caller ID not found or invalid type');
        }
    });
});

// Function to handle call initiation
function handleCall(from, to) {
    // Your call initiation logic here
    if (clients.has(to)) {
        const recipient = clients.get(to);
        const caller = clients.get(from);
        caller.emit('ringing', { to: to });
        recipient.emit('incoming_call', { from: from });
        console.log(`Initiating call from '${from}' to '${to}'`);
    } else {
        console.log(`User '${to}' is not connected.`);
        const caller = clients.get(from);
        caller.emit('recipient_not_available', { to: to });
    }
}
