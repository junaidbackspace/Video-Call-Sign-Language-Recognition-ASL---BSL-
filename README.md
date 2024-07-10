![IMG_9237](https://github.com/junaidbackspace/Video-Call-Sign-Language-Recognition-ASL---BSL-/assets/88697352/6b6cf6b4-9ca7-43a4-a9ee-f026ca3d0f8f)
Adding Person in Video Call
![IMG_9238](https://github.com/junaidbackspace/Video-Call-Sign-Language-Recognition-ASL---BSL-/assets/88697352/8b5e19fc-75ef-4ba4-81fd-1c80e6a5c4f6)
Recieving Group Call
![IMG_9239](https://github.com/junaidbackspace/Video-Call-Sign-Language-Recognition-ASL---BSL-/assets/88697352/b54168d7-9afd-4b27-8607-137709cf686d)
Group member Screen
![IMG_9241](https://github.com/junaidbackspace/Video-Call-Sign-Language-Recognition-ASL---BSL-/assets/88697352/a24bb2b0-c4af-479d-9020-516b99dbb86d)



# Database
https://drive.google.com/file/d/11BKq20Dmcqw-w9JJ1UgM_yli9CJhDcGx/view?usp=sharing

# Api's
https://drive.google.com/file/d/1xnK7YzgPjuVap1l7g94OyN_RAiNMYRnh/view?usp=sharing


# Feature

- Fast API's (Load Balancer )Technology used
- Real time Signs Recognition in Video Call
- Support Group Call by (2 devices peer to peer video call - others by socket)
- For Deaf & Dumb video Call by default it Detects (Alphabets) on Double Tap it shifted to Detect (Words - Sentences)
- Allows to Create Custom Signs by using (Vision Transformers)
- In Video Call Sign Language Animations .GIF Integrated for Deaf & Dumb along with Text of caller Communication
- Text to speech for Blind Integrated
- Lessons for learning Sign Language Integrated
- Text Size , Color , Opacity for video Call Screen Provided


# Dependency

- Xcode version 10.3
- Swift version 5
- Starscream
- KingFisher
- SwiftGifOrigin
- GoogleWebRTC

# Setup

- `pod install`
- You need to setup signaling server.  
  This project includes simple one at `CommFusion/SignalingServer/`.  
  You can setup node.js as folows.
  - `cd CommFusion/SignalingServer`
  - `npm install`

# Usage

- Firstly, run the signaling server as folows.
  - `cd CommFusion/SignalingServer`
  - `node server.js`
    node.js server will start at 8080 port.
- Change signaling server url ( the `ipAddress` String vallue) to your case in [Structs](./Comm Fusion/Structs/ServerIP.swift). You can find your signaling server     url in signaling server log.
  
- Enjoy.

# Licence

This software is for Educational Purpose by Junaid Arif.
