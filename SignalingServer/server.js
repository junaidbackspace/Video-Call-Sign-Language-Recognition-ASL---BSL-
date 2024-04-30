"use strict";

let WebSocketServer = require('ws').Server;
let port = 8080;
let wsServer = new WebSocketServer({ port: port });
const ip = require('ip');
console.log('websocket server start.' + ' ipaddress = ' + ip.address() + ' port = ' + port);

// Map to store WebSocket connections with their IDs
const clients = new Map();
const callers = new Map();


wsServer.on('connection', function (ws) {
   

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
                // ws.close();
                console.log(`Connection closed: User ID '${userId}' is already in use.`);
                return;
            }
            // Save the WebSocket connection with the provided user ID
            clients.set(userId, ws);
            
            console.log(`User '${userId}' authenticated and connected.`);
        } catch (error) {
            ws.close();
            console.error('Error handling authentication message: user not found', error);
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

    
    ws.on('message', function (message) {

       
        try {
            const data = JSON.parse(message);
            const { type, from, to, sdp, candidate } = data; // Extract necessary fields from the received message
            
            //call initiated
            if (data.type === 'call') {
                handleCall(data.from, data.to);
                
            }
                    
            //on call accepted
            if (type === 'call_accept') {
                console.log('call is accepted by ',from ,'caller is : ',to)
                if (clients.has(from) && clients.has(to)) {
                    // Store the WebSocket connections associated with the sender and recipient user IDs
                    callers.set(from, ws);
                    callers.set(to, ws);
                    console.log(`User IDs '${from}' and '${to}' saved for video call.`);
                    
                    // Notify the recipient about the call initiation
                    
                    const recipient = clients.get(to);
                    console.log(JSON.stringify({ type: 'call_accepted' }))
                    recipient.send(JSON.stringify({ type: 'call_accepted' })); // Forward the call initiation message to the recipient
                  
                    

                } else {
                    console.log(`User IDs '${from}' and '${to}' are already associated with a video call.`);
                }
                
                    
             } else if (type === 'sdp' || type === 'candidate' || type === 'offer' || type === 'answer') {
                if (clients.has(from) && clients.has(to)) {
                    // Store caller and recipient WebSocket connections
                    // callers.set(from, clients.get(from));
                    // callers.set(to, clients.get(to));
            
                    // const callInitiator = clients.get(to);
                    // const callReceiver = clients.get(from);
            
                    // console.log('from: ', from, ' to: ', to, ' type: ', type);
                    

                   
            wsServer.clients.forEach(function each(client) {
   
          for (const [userId, ws] of callers) {
       
               if (isSame(ws, client)) {
                //    console.log('Skip sender:', type, 'WebSocket ID: ',userId);
                      } else {
                         console.log('sending  message:', type, 'to : ',userId);
                           client.send(message);
                              }
    }
});

                    // wsServer.clients.forEach(function each(client) {
                    //     if (isSame(ws, client)) {

                    //         console.log('skip sender:',type,'ws id ');
                    //     }
                    //     else {
                    //         client.send(message);
                    //     }
                    // });
                    
                //     callers.forEach(function each(client, clientId) {
                //         console.log('within loop type: ',type)
                //         if ( type === 'offer'){
                // console.log('entered in offer')
                //             if (clientId === from) {
                //             // Send offer to the caller
                //             client.send(message);
                //             console.log('Offer: ',type)
                //         } 
                //     }
                //     else if ( type=== 'answer'){
                //  console.log('entered in Answer')
                //         if (clientId === to) {
                //             // Send answer to the call Reciever
                //             client.send(message);
                //             console.log('Answer: ',type)
                //         } 

                //     }
                //     else{
                //         callers.forEach(function each(client) {
                //             if (isSame(ws, client)) {
                //                 console.log('skip sender');
                //             }
                //             else {
                //                 client.send(message);
                //             }
                //         });
                    
                //     }
                //     });
                
                // } else {
                //     console.log(`Caller or recipient not found`);
                // }
            }
        }     
           else if ( type === 'call_ended')
           {
            const callerID =  clients.get(data.callerID);
            if (callerID) {
                console.log("sending call ending msg to user ID:", data.callerID);
                const recipient = clients.get(callerID);
                recipient.send(JSON.stringify({ type: 'call_ended' }));
                
            } else {
                console.log("Caller ID not found or invalid type");
            }
           }
            else {
                // Handle other types of messages (if any)
            }
        } catch (error) {
            const json = JSON.parse(message.toString());
        }
        
    });

    
});

function isSame(ws1, ws2) {
    // -- compare object --
    return (ws1 === ws2);
}

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



