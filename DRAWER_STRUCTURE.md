# Chat Drawer Structure

## Visual Hierarchy

```
┌─────────────────────────────────────┐
│  ∞ COLAB                         ✕  │  ← Header
├─────────────────────────────────────┤
│  + New Chat                         │  ← New Chat Button
├─────────────────────────────────────┤
│  🔍 Search chats...                 │  ← Search Bar
├─────────────────────────────────────┤
│                                     │
│  ┌─ PROJECTS ──────────── 📁 ▼ ─┐  │  ← Projects Section
│  │  📁 Restaurant          › ⋯   │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─ CONTEXTS ──────────── + ▼ ──┐  │  ← Contexts Section
│  │  ☑ My Name                ⋯   │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─ ASSISTANTS ──────────── ▼ ──┐  │  ← Assistants Section
│  │  </> Software Engineer        │  │
│  │  ✏️ Content Writer            │  │
│  │  ⚖️ Legal Advisor              │  │
│  │  📢 Marketing                  │  │
│  │  Load More Assistants          │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─ CHATS ────────────────── ▼ ─┐  │  ← Chats Section
│  │  ⭐ Starred Messages           │  │
│  │  💬 Hello                  ⋯   │  │
│  │  💬 Hello colab            ⋯   │  │
│  │  💬 hey Manan how a...     ⋯   │  │
│  │  💬 hello                  ⋯   │  │
│  │  💬 hello                  ⋯   │  │
│  │  💬 what can you fo...     ⋯   │  │
│  │  Load More Chats               │  │
│  └─────────────────────────────┘  │
│                                     │
├─────────────────────────────────────┤
│  👤 Super Admin              ⋯     │  ← Profile Footer
│     superadmin@aicolab.com         │
└─────────────────────────────────────┘
```

## Component Breakdown

### 1. Header
- **Logo**: Infinity symbol in gradient circle
- **Title**: "COLAB" in bold uppercase
- **Close Button**: X icon to close drawer

### 2. New Chat Button
- **Icon**: Plus (+) symbol
- **Text**: "New Chat"
- **Action**: Creates new conversation and closes drawer

### 3. Search Bar
- **Icon**: Magnifying glass
- **Placeholder**: "Search chats..."
- **Function**: Filter chats (ready for implementation)

### 4. Projects Section (Collapsible)
- **Header**: "PROJECTS" with folder icon and dropdown arrow
- **Items**: 
  - Folder icon
  - Project name
  - Chevron (›) for navigation
  - More options (⋯)

### 5. Contexts Section (Collapsible)
- **Header**: "CONTEXTS" with add (+) icon and dropdown arrow
- **Items**:
  - Checkbox (checked/unchecked)
  - Context name
  - More options (⋯)

### 6. Assistants Section (Collapsible)
- **Header**: "ASSISTANTS" with dropdown arrow
- **Items**:
  - Icon representing assistant type
  - Assistant name
- **Footer**: "Load More Assistants" button

### 7. Chats Section (Collapsible)
- **Header**: "CHATS" with dropdown arrow
- **Subsection**: "Starred Messages" with star icon
- **Items**:
  - Chat bubble icon
  - Chat title (truncated if long)
  - More options (⋯)
  - Highlight if selected
- **Footer**: "Load More Chats" button

### 8. Profile Footer
- **Avatar**: Circular profile image with gradient border
- **Name**: User's display name
- **Email**: User's email address
- **More Options**: Three dots (⋯) for menu

## Interaction Patterns

### Section Headers
- **Tap**: Expand/collapse section
- **Visual Feedback**: Arrow rotates (› to ▼)

### Chat Items
- **Tap**: Select chat and navigate to conversation
- **More Button**: Opens bottom sheet with options:
  - ✏️ Rename
  - ⭐ Star
  - 🗑️ Delete (red)

### Profile Footer
- **More Button**: Opens bottom sheet with options:
  - 👤 Profile
  - ⚙️ Settings
  - ❓ Help & Support
  - 🚪 Logout (red)

## Color Palette

```dart
Background:        Colors.black
Borders:           AppColors.darkBorder (with alpha)
Primary Text:      AppColors.darkForeground
Secondary Text:    AppColors.darkMutedForeground
Accent:            AppColors.landingPrimary
Star:              Colors.amber
Destructive:       Colors.red
Selected:          AppColors.darkCard (with alpha)
```

## Spacing Guidelines

```dart
Drawer Width:      85% of screen width
Horizontal Padding: 16px
Section Spacing:   12px
Item Padding:      12px horizontal, 10-12px vertical
Border Radius:     8px
Icon Size:         18-22px
```

## State Management

### Local State (in ChatDrawer)
- `_projectsExpanded`: bool
- `_contextsExpanded`: bool
- `_assistantsExpanded`: bool
- `_chatsExpanded`: bool
- `_searchController`: TextEditingController

### BLoC State (ChatBloc)
- `conversations`: List of all chats
- `selectedConversation`: Currently active chat
- `messages`: Messages in selected chat

### Auth State (AuthBloc)
- `user`: Current user info for profile footer

## File Organization

```
lib/features/chat/presentation/widgets/
├── chat_drawer.dart                    (Main drawer widget)
└── drawer_sections/
    ├── drawer_header.dart              (Logo + close button)
    ├── drawer_search_bar.dart          (Search input)
    ├── section_header.dart             (Reusable header)
    ├── projects_section.dart           (Projects list)
    ├── contexts_section.dart           (Contexts list)
    ├── assistants_section.dart         (Assistants list)
    ├── chats_section.dart              (Chats list)
    └── drawer_profile_footer.dart      (User profile)
```

## Integration Points

### ChatBloc Events
- `ChatStartNewConversation()` - New Chat button
- `ChatSelectConversation(conversation)` - Chat item tap
- `ChatDeleteConversation(conversationId)` - Delete action

### AuthBloc Events
- `AuthLogoutRequested()` - Logout action

### Navigation
- `Navigator.pop(context)` - Close drawer after action
- Route navigation ready for profile/settings pages

---

**Note**: This structure matches the AI Fiesta design shown in the reference images with clean architecture and modular components.
