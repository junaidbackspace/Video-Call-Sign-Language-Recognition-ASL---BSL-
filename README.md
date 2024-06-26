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
