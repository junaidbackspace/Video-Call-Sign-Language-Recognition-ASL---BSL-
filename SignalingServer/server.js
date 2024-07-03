"use strict";

let WebSocketServer = require('ws').Server;
let port = 8081;
let wsServer = new WebSocketServer({ port: port });
const ip = require('ip');
console.log('websocket server start.' + ' ipaddress = ' + ip.address() + ' port = ' + port);

// Map to store WebSocket connections with their IDs
const clients = new Map();
const callers = new Map();
const groupchat_members = new Map();

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
            callers.delete(userId);
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
            const { type, from, to, sessionDescription, candidate,videocallid , caller1 ,caller2 ,newUser ,msg} = data; // Extract necessary fields from the received message
            
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
                    
//<<<<<<< HEAD
   }
         
         
        }     
           else if ( type === 'call_ended')
           {
            const callerID =  clients.get(data.callerID);
            const callenderID = clients.get(data.callenderID);
            if (callerID) {
                
                console.log("sending call ending msg to user ID:", data.callerID);
                
                callerID.send(JSON.stringify({ type: 'call_ended' }));
//=======
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
                
               else if (data.type === 'classStart') {
                   console.log(" group chat");
                 handleClassChat(data.newUser,data.from);

              }
                
              else if (data.type === 'groupchat') {
                  console.log(" group chat");
                handleGroupChat(data.caller1, data.caller2 , data.newUser,data.videocallid);

             }

            else if (data.type === 'group_call_accepted') {
                console.log(" group chat accepted");
               
                    
                    const caller1 = clients.get(data.caller1); // user
                    const caller2 = clients.get(data.caller2);
                    
                    console.log("ringing")
                   
                    caller1.send(JSON.stringify({ type: 'group_chat_accept',chatuserid: data.from}));
                    console.log(`Sending Group chat accept Noti to : '${data.caller1}' by : '${data.from}'`);
                    caller2.send(JSON.stringify({ type: 'group_chat_accept',chatuserid: data.from }));
                    console.log(`Sending Group chat accept Noti to : '${data.caller2}' by : '${data.from}'`);
                   
            
        }
//>>>>>>> 143f9eb (teach screens completed)
                
               
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
          else if (data.type === 'groupchat') {
              console.log(" group chat");
            handleGroupChat(data.caller1, data.caller2 , data.newUser,data.videocallid);

         }

        else if (data.type === 'group_call_accepted') {
            console.log(" group chat accepted");
           
                
                const caller1 = clients.get(data.caller1); // user
                const caller2 = clients.get(data.caller2);
                
                console.log("ringing")
               
                caller1.send(JSON.stringify({ type: 'group_chat_accept',chatuserid: data.from}));
                console.log(`Sending Group chat accept Noti to : '${data.caller1}' by : '${data.from}'`);
                caller2.send(JSON.stringify({ type: 'group_chat_accept',chatuserid: data.from }));
                console.log(`Sending Group chat accept Noti to : '${data.caller2}' by : '${data.from}'`);
               
        
    }
            
        else if (data.type === 'group_call_end') {
           
                const caller1 = clients.get(data.caller1); // user
                const caller2 = clients.get(data.caller2);
                
                console.log("Group member leaved")
               
                caller1.send(JSON.stringify({ type: 'ChatmemberEnds_groupchat',chatuserid: data.from}));
                console.log(`Sending Group chat End Noti to : '${data.caller1}' by : '${data.from}'`);
                caller2.send(JSON.stringify({ type: 'ChatmemberEnds_groupchat',chatuserid: data.from }));
                console.log(`Sending Group chat End Noti to : '${data.caller2}' by : '${data.from}'`);
               
        
    }

    else if (data.type === 'groupMsg') {
        console.log("Chat msg Recived : ",data.msg)
        const member = clients.get(data.to);
        member.send(JSON.stringify({type: 'msg' , msg: data.msg , chatsender : data.from}))
       console.log("sending GroupChat member msg to ",data.to)
       
    }

    else if (data.type === 'groupchatend') {
        const member = clients.get(data.to);
       member.send(JSON.stringify({ type: 'groupChat_ended' }));
         console.log("Sending End GroupChat Msg to ",data.to)       
       
    }
    else {
        // Handle other types of messages (if any)
    }
}
 catch (error) {
    const json = JSON.parse(message.toString());
}
});

        
//<<<<<<< HEAD



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

function handleGroupChat(c1, c2,user , v_id) {
    // Check if the recipient (to) is connected
    console.log("within group call ");
    if (clients.has(user)) {
        const recipient = clients.get(user); //friend
        
        groupchat_members.set(user , recipient)
        const caller1 = clients.get(c1); // user
        const caller2 = clients.get(c2);
        // Send call initiation message to the recipient
        if (callers.has(user)) {
            caller1.send(JSON.stringify({ type: 'busy', to: to }));
            console.log(`User  '${user}' is busy on other call `);
            return;
        }
        else{
        console.log("ringing")
        //caller1.send(JSON.stringify({ type: 'ringing', to: to }));
        //caller2.send(JSON.stringify({ type: 'ringing', to: to }));

        recipient.send(JSON.stringify({ type: 'incoming_group_call', user1: c1 ,user2: c2, vid: v_id}));
        console.log(`Initiating call from '${c1} & ${c2}' to '${user}' videocall id : '${vid}'`);
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
    
    
});
//=======
        function handleClassChat(user,teacher) {
            // Check if the recipient (to) is connected
            console.log("within class call ");
            if (clients.has(user)) {
                
                const recipient = clients.get(user); //chat friend
                
                groupchat_members.set(user , recipient)
                const caller1 = clients.get(teacher); // user
                
                // Send call initiation message to the recipient
                if (callers.has(user)) {
                    caller1.send(JSON.stringify({ type: 'busy', to: to }));
                    console.log(`User  '${user}' is busy on other call `);
                    return;
                }
                else{
                console.log("ringing")
                //caller1.send(JSON.stringify({ type: 'ringing', to: to }));
                //caller2.send(JSON.stringify({ type: 'ringing', to: to }));

                recipient.send(JSON.stringify({ type: 'incoming_class_call', user1: teacher }));
                console.log(`Initiating call from '${teacher} & ${user}' to '${user}' videocall id : '${vid}'`);
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
        
        
    });
//>>>>>>> 143f9eb (teach screens completed)
