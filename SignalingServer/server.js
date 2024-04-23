"use strict";

let WebSocketServer = require('ws').Server;
let port = 8080;
let wsServer = new WebSocketServer({ port: port });
const ip = require('ip');
console.log('websocket server start.' + ' ipaddress = ' + ip.address() + ' port = ' + port);

// Map to store WebSocket connections with their IDs
const clients = new Map();

wsServer.on('connection', function (ws) {
    console.log('-- websocket connected --');

    // Handle incoming authentication message
    ws.once('message', function (message) {
        try {
            const data = JSON.parse(message);
            const userId = data.userId;
            if (!userId) {
                ws.close();
                console.log('Connection closed: No user ID provided.');
                return;
            }
            if (clients.has(userId)) {
                ws.close();
                console.log(`Connection closed: User ID '${userId}' is already in use.`);
                return;
            }
            // Save the WebSocket connection with the provided user ID
            clients.set(userId, ws);
            console.log(`User '${userId}' authenticated and connected.`);
        } catch (error) {
            ws.close();
            console.error('Error handling authentication message:', error);
        }
    });

    // Handle incoming messages
    ws.on('message', function (message) {
        console.log('-- message received --');
        try {
            const data = JSON.parse(message);
            if (data.type === 'call') {
                handleCall(data.from, data.to);
            } else {
                // Handle other types of messages (if any)
            }
        } catch (error) {
            console.error('Error handling message:', error);
        }
    });

    // Handle disconnection
    ws.on('close', function () {
        // Remove the WebSocket connection from the clients map
        for (const [userId, client] of clients) {
            if (client === ws) {
                clients.delete(userId);
                console.log(`User '${userId}' disconnected.`);
                break;
            }
        }
    });

    // Handle errors
    ws.on('error', function (error) {
        console.error('WebSocket error:', error);
    });
});

// Function to handle call initiation
function handleCall(from, to) {
    // Check if the recipient (to) is connected
    if (clients.has(to)) {
        const recipient = clients.get(to); //friend
        const caller = clients.get(from); // user
        // Send call initiation message to the recipient

        caller.send(JSON.stringify({ type: 'ringing', to: to }));
        recipient.send(JSON.stringify({ type: 'incoming_call', from: from }));
        console.log(`Initiating call from '${from}' to '${to}'`);
        return `Initiating call from '${from}' to '${to}'`;
    } else {
        console.log(`User '${to}' is not connected.`);
        // Optionally, you can send a message back to the caller indicating that the recipient is not available
        const caller = clients.get(from);
        caller.send(JSON.stringify({ type: 'recipient_not_available', to: to }));
        return `User '${to}' is not connected.`;
    }
}

