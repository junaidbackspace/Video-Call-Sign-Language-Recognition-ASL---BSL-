"use strict";

let WebSocketServer = require('ws').Server;
let port = 8081;
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
            //    ws.close();
                console.log(`Connection for: User ID '${userId}' is already in use.`);
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
   
    // Iterate over clients to find the disconnected client
    clients.forEach((client, userId) => {
        if (client === ws) {
            clients.delete(userId);
            console.log(`User '${userId}' disconnected.`);
            return;
        }
    });
});


    // Handle errors
    ws.on('error', function (error) {
        console.error('WebSocket error:', error);
    });

    
    ws.on('message', function (message) {

       
        try {
            const data = JSON.parse(message);
            const { type, from, to, sessionDescription, candidate,videocallid } = data; // Extract necessary fields from the received message
            
            //call initiated
            if (data.type === 'call') {
                handleCall(data.from, data.to , data.videocallid);
                
            }
                    
            //on call accepted
           else if (type === 'call_accept') {
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
                
                    
             } 
    else if (type === 'sdp' || type === 'candidate' || type === 'offer' || type === 'answer') 
    {
        var loopcheck = true;
       
        if (clients.has(from) && clients.has(to)) {
                    
         wsServer.clients.forEach(function each(client) {
            if (loopcheck === true){
          for (const [userId, wss] of callers) {

             if (to === userId) {
                // console.log('Skip sender:', type, 'WebSocket ID: ',userId);
                   
                      }
                else {
                   
                    console.log('\n: ',type);
                    // console.log('sending  message:', type, 'to : ',userId);
                    var user = clients.get(userId);
                    user.send(message);
                     loopcheck = false;
                     break;
                   
                    }
    }
}
});
                    
   }
         
         
        }     
           else if ( type === 'call_ended')
           {
            const callerID =  clients.get(data.callerID);
            const callenderID = clients.get(data.callenderID);
            if (callerID) {
                
                console.log("sending call ending msg to user ID:", data.callerID);
                
                callerID.send(JSON.stringify({ type: 'call_ended' }));
                
               
                callers.delete(data.callerID);
                callers.delete(data.callenderID);
            } else {
                console.log("Caller ID not found or invalid type");
            }
           }
           else if ( type === 'cancellcall')
           {
            const callerID =  clients.get(data.from);
            const callenderID = clients.get(data.to);
            if (callenderID) {
                
                console.log("sending call Cancell msg to user ID:", data.to);
                
                callenderID.send(JSON.stringify({ type: 'call_cancell' }));
                
                
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



// Function to handle call initiation
function handleCall(from, to,vid) {
    // Check if the recipient (to) is connected
    if (clients.has(to)) {
        const recipient = clients.get(to); //friend
        const caller = clients.get(from); // user
        // Send call initiation message to the recipient
        if (callers.has(to)) {
            caller.send(JSON.stringify({ type: 'busy', to: to }));
            console.log(`User  '${to}' is busy on other call '${to}'`);
            return;
        }else{
        caller.send(JSON.stringify({ type: 'ringing', to: to }));
        recipient.send(JSON.stringify({ type: 'incoming_call', from: from , vid: vid}));
        console.log(`Initiating call from '${from}' to '${to}' videocall id : '${vid}'`);
        return `Initiating call from '${from}' to '${to}'`;
        }
    } else {
        console.log(`User '${to}' is not connected.`);
        // Optionally, you can send a message back to the caller indicating that the recipient is not available
        const caller = clients.get(from);
        caller.send(JSON.stringify({ type: 'recipient_not_available', to: to }));
        return `User '${to}' is not connected.`;
    }
}



