# Step 1: Problem Statement Analysis - Facebook Data Model

## Problem Statement

**"Create a Data Model for Facebook"**

---

## Understanding the Problem

### What is Facebook?

Facebook is a **social networking platform** where users:
- Create personal profiles with rich information
- Connect with friends and family
- Share posts (text, photos, videos, links)
- Interact through likes, comments, and shares
- Join and participate in groups
- Create and attend events
- Send messages (Messenger)
- Follow pages (brands, celebrities, organizations)
- React with different emotions (Like, Love, Haha, Wow, Sad, Angry)
- Tag friends in posts and photos
- Check in at locations
- Share stories (24-hour content)

---

## Core Requirements Analysis

### 1. User Management
**What we need:**
- User profiles with extensive personal information
- Profile pictures and cover photos
- Bio, education, work history
- Location and contact information
- Privacy settings per user
- Account status (active, deactivated, deleted)

**Why it matters:**
- Identity and personalization
- Rich social profiles
- Privacy control
- User trust and safety

---

### 2. Friend Connections
**What we need:**
- Friend requests (pending, accepted, rejected)
- Bidirectional friendships (mutual)
- Friend lists and categorization
- Unfriend capability
- Block functionality

**Why it matters:**
- Core social graph
- Content visibility control
- Privacy boundaries
- Relationship management

---

### 3. Content Creation (Posts)
**What we need:**
- Text posts
- Photo posts (single or albums)
- Video posts
- Link sharing
- Status updates
- Post privacy settings (Public, Friends, Custom)
- Post location/check-in
- Feeling/activity tags

**Why it matters:**
- Primary content type
- User expression
- Engagement driver
- Platform value

---

### 4. Engagement Mechanisms
**What we need:**
- Reactions (Like, Love, Haha, Wow, Sad, Angry)
- Comments (with nested replies)
- Shares (to timeline or groups)
- Tags (people in posts/photos)
- Mentions in comments

**Why it matters:**
- User interaction
- Content amplification
- Conversation depth
- Social validation

---

### 5. Groups
**What we need:**
- Group creation and management
- Group types (Public, Private, Secret)
- Group membership (admin, moderator, member)
- Group posts and discussions
- Group events
- Group files and media

**Why it matters:**
- Community building
- Topic-based interaction
- User engagement
- Platform stickiness

---

### 6. Pages
**What we need:**
- Business/brand pages
- Page categories
- Page followers (not friends)
- Page posts
- Page admins and roles
- Page reviews and ratings

**Why it matters:**
- Business presence
- Brand communication
- Monetization
- Content diversity

---

### 7. Events
**What we need:**
- Event creation
- Event details (date, time, location)
- Event privacy settings
- RSVP status (Going, Interested, Not Going)
- Event posts and discussions
- Event invitations

**Why it matters:**
- Real-world coordination
- Community engagement
- Event discovery
- Social planning

---

### 8. Messaging (Messenger)
**What we need:**
- One-on-one conversations
- Group chats
- Message content (text, media, links)
- Read receipts
- Message reactions
- Voice/video call history

**Why it matters:**
- Private communication
- Real-time interaction
- User retention
- Platform utility

---

### 9. Photos and Albums
**What we need:**
- Photo uploads
- Photo albums
- Photo tags (people in photos)
- Photo comments and reactions
- Album privacy settings

**Why it matters:**
- Visual content
- Memory preservation
- High engagement
- User-generated content

---

### 10. Notifications
**What we need:**
- Activity notifications
- Friend requests
- Post interactions
- Group updates
- Event reminders
- Birthday reminders

**Why it matters:**
- User engagement
- Return visits
- Real-time updates
- Platform activity

---

## Scope Definition

### In Scope (Basic Level):
✅ User profiles and authentication
✅ Friend connections (bidirectional)
✅ Posts (text, photos, videos)
✅ Reactions (6 types)
✅ Comments (with nested replies)
✅ Shares
✅ Groups (creation, membership, posts)
✅ Pages (creation, followers, posts)
✅ Events (creation, RSVP)
✅ Photo albums and tags
✅ Messages (one-on-one and group)
✅ Notifications
✅ Privacy settings

### Out of Scope (Advanced Features):
❌ Facebook Marketplace
❌ Facebook Dating
❌ Facebook Gaming
❌ Facebook Watch (video platform)
❌ Facebook Stories (24-hour content)
❌ Facebook Live streaming
❌ Ads and promoted content
❌ Advanced analytics
❌ Fundraisers
❌ Polls
❌ Facebook Pay
❌ Oculus/VR integration
❌ Instagram/WhatsApp integration

---

## Key Challenges to Address

### 1. Bidirectional Friendships
**Challenge:** Unlike Twitter's follow model, Facebook friendships are mutual
**Solution:** Friend requests with acceptance required

### 2. Complex Privacy Settings
**Challenge:** Posts can be Public, Friends-only, or Custom
**Solution:** Privacy level field with granular controls

### 3. Nested Comments
**Challenge:** Comments can have replies (threaded discussions)
**Solution:** Self-referencing comments table

### 4. Multiple Reaction Types
**Challenge:** Not just "like" but 6 different reactions
**Solution:** Reaction type enum in reactions table

### 5. Content on Multiple Entities
**Challenge:** Posts can be on user timelines, groups, or pages
**Solution:** Polymorphic association or separate post types

### 6. Photo Tagging
**Challenge:** Multiple people can be tagged in one photo
**Solution:** Many-to-many relationship with photo_tags junction table

### 7. Group Roles
**Challenge:** Different permission levels (admin, moderator, member)
**Solution:** Role field in group_members table

### 8. Event RSVPs
**Challenge:** Multiple response types (Going, Interested, Not Going)
**Solution:** RSVP status enum in event_attendees table

---

## Data Model Goals

### 1. Normalization
- Eliminate data redundancy
- Maintain data integrity
- Follow 3NF principles
- Use junction tables for M:N relationships

### 2. Performance
- Fast news feed generation
- Efficient friend queries
- Quick notification retrieval
- Optimized photo loading

### 3. Scalability
- Handle billions of users
- Support trillions of posts
- Manage high concurrent access
- Enable horizontal scaling

### 4. Flexibility
- Support multiple content types
- Enable privacy controls
- Allow feature extensions
- Accommodate business logic

---

## Business Rules to Implement

### User Rules:
1. Email must be unique
2. Username must be unique (if used)
3. Users must be 13+ years old
4. Profile can be public or private
5. Users can deactivate accounts

### Friendship Rules:
1. Friendships are bidirectional (mutual)
2. Friend request must be accepted
3. Cannot send duplicate friend requests
4. Can unfriend at any time
5. Can block users (prevents all interaction)

### Post Rules:
1. Posts belong to user, group, or page
2. Privacy settings: Public, Friends, Custom
3. Deleted posts are soft-deleted
4. Posts can have location tags
5. Posts can tag multiple users

### Reaction Rules:
1. One user can react to a post only once
2. Can change reaction type
3. Removing reaction deletes record
4. 6 reaction types: Like, Love, Haha, Wow, Sad, Angry

### Comment Rules:
1. Comments can have nested replies
2. Comments can be on posts or other comments
3. Users can delete their own comments
4. Comment authors can be tagged

### Group Rules:
1. Groups have privacy levels (Public, Private, Secret)
2. Members have roles (admin, moderator, member)
3. Only members can see private group content
4. Admins can remove members

### Page Rules:
1. Pages are followed, not friended
2. Pages have categories
3. Multiple admins allowed
4. Pages can post content
5. Users can review/rate pages

### Event Rules:
1. Events have privacy settings
2. RSVP status: Going, Interested, Not Going
3. Events can be created by users, groups, or pages
4. Event invitations sent to friends

---

## Success Metrics

Our data model should support queries for:

1. **News Feed:** Get posts from friends, groups, and pages
2. **User Profile:** Get all user information and posts
3. **Friend Suggestions:** Recommend friends based on mutual connections
4. **Group Activity:** Get posts and members in a group
5. **Event Management:** Get RSVPs and attendees
6. **Photo Albums:** Get photos with tags
7. **Notifications:** Get user's recent activity
8. **Search:** Find users, groups, pages, events
9. **Messaging:** Get conversations and messages
10. **Analytics:** Engagement metrics per post

---

## Entity Categories

### Core Entities:
- users
- friendships
- posts
- reactions
- comments
- shares

### Community Entities:
- groups
- group_members
- pages
- page_followers

### Event Entities:
- events
- event_attendees

### Media Entities:
- photos
- photo_albums
- photo_tags

### Communication Entities:
- messages
- conversations
- conversation_participants

### Supporting Entities:
- notifications
- privacy_settings
- locations

---

## Key Relationships

### User-Centric:
- Users ↔ Users (friendships - bidirectional)
- Users → Posts (content creation)
- Users → Reactions (engagement)
- Users → Comments (discussion)

### Group-Centric:
- Users ↔ Groups (membership)
- Groups → Posts (group content)
- Groups → Events (group events)

### Page-Centric:
- Users ↔ Pages (followers)
- Pages → Posts (page content)
- Pages → Events (page events)

### Content-Centric:
- Posts ↔ Users (tags)
- Posts → Comments (discussion)
- Posts → Reactions (engagement)
- Photos ↔ Users (tags)

---

## Next Steps

With this problem analysis complete, we will:

1. ✅ **Step 1:** Problem diagnosis (CURRENT)
2. ⏭️ **Step 2:** Identify and explain entities
3. ⏭️ **Step 3:** Establish relationships
4. ⏭️ **Step 4:** Create data model diagram
5. ⏭️ **Step 5:** Write SQL queries

---

## Summary

**Problem:** Design a relational database for a Facebook-like social networking platform

**Core Entities Needed:**
- Users, Friendships, Posts, Reactions, Comments
- Groups, Pages, Events
- Photos, Albums, Messages
- Notifications, Privacy Settings

**Key Relationships:**
- Users ↔ Users (bidirectional friendships)
- Users ↔ Groups (membership with roles)
- Users ↔ Pages (followers)
- Posts → Comments (threaded discussions)
- Photos ↔ Users (tagging)

**Design Principles:**
- Normalize to 3NF
- Support bidirectional relationships
- Enable granular privacy
- Plan for massive scale
- Support rich media

**Unique Facebook Features:**
- Bidirectional friendships (vs Twitter's follow)
- Multiple reaction types (vs simple like)
- Groups with roles
- Pages (business presence)
- Events with RSVPs
- Photo tagging
- Nested comments

---

This analysis provides the foundation for our Facebook data model design!
