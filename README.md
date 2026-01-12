# JS Full Stack Applications - Advanced FiveM Server Management System

A comprehensive, feature-rich web application for managing FiveM roleplay server applications, support tickets, user management, and administrative operations. Built with Next.js 15, TypeScript, and Discord OAuth integration with the help of AI.

## 🌟 Overview

JS-Applications is a modern, full-stack management system designed specifically for FiveM roleplay servers. It provides a complete solution for handling player applications, support tickets, announcements, shop integration, and administrative oversight with a beautiful, responsive UI.

## ✨ Key Features

### 🎯 Application Management System
- **Multi-Type Applications**: Support for custom application types with configurable fields
- **Dynamic Form Builder**: Create custom application forms with text, textarea, number, select, and checkbox fields
- **Status Tracking**: Manage applications through pending, approved, denied, and archived states
- **Priority System**: Four-level priority system (low, normal, high, urgent) with visual indicators
- **Smart Filtering**: Advanced filtering by status, priority, date range, age, and assigned staff
- **Assignment System**: Assign applications to specific staff members for review
- **Notes System**: Internal notes for staff communication on applications
- **Application History**: View complete history of all user applications
- **Cooldown Management**: Configurable cooldown periods between applications per type
- **Duplicate Prevention**: Prevent multiple pending or approved applications based on type settings
- **Bulk Operations**: Approve, deny, or delete multiple applications simultaneously
- **Export Functionality**: Export applications to CSV or JSON formats
- **Application Drafts**: Auto-save drafts to prevent data loss

### 🎫 Support Ticket System
- **Multi-Category Tickets**: Technical, rule violations, refunds, and general inquiries
- **Priority Levels**: Four-tier priority system with color coding
- **Status Management**: Open, in progress, resolved, and closed states
- **Real-time Notifications**: Notify users when staff replies to their tickets
- **Admin Notifications**: Alert staff when new tickets are created
- **Note System**: Add internal notes and public replies to tickets
- **Priority Color Coding**: Visual priority indicators across all ticket views
- **Discord Integration**: Automatic Discord notifications for ticket events

### 👥 User Management
- **Ban System**: Temporary and permanent bans with expiration dates
- **Blacklist System**: Permanent blacklist with reason tracking
- **Discord Integration**: Seamless Discord OAuth authentication
- **Role-Based Permissions**: Granular permission system with custom roles
- **User Activity Tracking**: Complete audit trail of user actions

### 📢 Announcement System
- **Multiple Types**: Maintenance, events, important updates, and community posts
- **Priority Levels**: High, medium, and low priority announcements
- **Rich Content**: Support for detailed announcement content
- **Public Display**: Beautiful announcement cards on homepage
- **Admin Management**: Full CRUD operations for announcements

### 🛡️ Advanced Admin Panel
- **Comprehensive Dashboard**: Overview of key metrics and statistics
- **Application Statistics**: 
  - Total applications with status breakdown
  - Approval rates and average review times
  - Applications by day chart
  - Applications by admin performance tracking
- **Activity Log**: Complete audit trail of all administrative actions including:
  - Application actions (created, approved, denied, archived, notes)
  - User management (bans, blacklist operations)
  - Ticket operations (created, updated, notes, deleted)
  - Announcement management
  - Rules updates
  - Application type management
  - Purchase tracking
  - Bulk operations
- **Notification Center**:
  - Application status changes
  - Ticket creation and updates
  - Mark as read functionality
  - Stale application alerts (7+ days pending)
  - Quick navigation to relevant items
- **Rules Management**: Visual rule editor with categories
- **Template System**: Save and reuse application response templates

### 🎨 User Interface
- **Modern Design**: Clean, professional interface with Tailwind CSS
- **Dark/Light Mode**: Full theme support with system preference detection
- **Responsive Layout**: Mobile-first design that works on all devices
- **Smooth Animations**: Framer Motion animations for enhanced UX
- **Loading States**: Beautiful loading indicators
- **Toast Notifications**: Non-intrusive feedback for user actions
- **Color-Coded Priority**: Visual priority system across applications and tickets

### 🔐 Security & Authentication
- **Discord OAuth 2.0**: Secure authentication via Discord
- **Session Management**: NextAuth.js for session handling
- **Role-Based Access Control**: Granular permission system
- **Protected Routes**: Middleware-based route protection
- **Server-Side Validation**: All inputs validated server-side

### 📊 Additional Features
- **Server Rules Display**: Public rules page with categorized sections
- **About Page**: Server information and details
- **Discord Server Status**: Real-time Discord server member count
- **Shop Integration**: PayPal integrated shop system
- **Email Notifications**: Optional email notifications (configurable)
- **Data Persistence**: JSON file-based storage (easily migrated to database)

## 🚀 Tech Stack

### Frontend
- **Next.js 15**: React framework with App Router
- **TypeScript**: Type-safe development
- **Tailwind CSS**: Utility-first CSS framework
- **Framer Motion**: Animation library
- **Lucide React**: Icon library
- **Radix UI**: Accessible UI components

### Backend
- **Next.js API Routes**: Server-side API
- **NextAuth.js**: Authentication
- **Node.js**: Runtime environment
- **File System**: JSON-based data storage

### Integrations
- **Discord API**: OAuth and bot integration
- **PayPal API**: Payment processing
- **Discord Webhooks**: Notifications

## 📦 Installation

### Prerequisites
- Node.js 18.x or higher
- npm or pnpm
- Discord Application (for OAuth)
- Discord Bot (for server integration)
- PayPal Business Account (optional, for shop)

### Setup Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/aura-applications.git
cd aura-applications
```

2. **Install dependencies**
```bash
npm install
# or
pnpm install
```

3. **Create environment file**
```bash
cp .env.example .env.local
```

4. **Configure environment variables** (see Configuration section below)

5. **Run development server** (data files will be created automatically)
```bash
npm run dev
# or
pnpm dev
```

6. **Open in browser**: `http://localhost:3000`

> **Note**: The application automatically creates all required JSON data files in the `/data` directory on first startup. No manual setup needed!

## 🔧 Configuration

### Environment Variables

Create a `.env.local` file in the root directory with the following variables:

```env
# NextAuth Configuration
# NextAuth Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here

# Discord OAuth
DISCORD_CLIENT_ID=your-discord-client-id
DISCORD_CLIENT_SECRET=your-discord-client-secret

# Discord Bot
DISCORD_BOT_TOKEN=your-bot-token
DISCORD_GUILD_ID=your-server-id
DISCORD_NOTIFICATION_CHANNEL_ID = your-notification-channel-id
DISCORD_PAYMENT_WEBHOOK_URL=your_webhook_url_here  # Optional
# PayPal (Optional)
NEXT_PUBLIC_PAYPAL_CLIENT_ID=your-paypal-client-id
PAYPAL_SECRET = your-paypal-secret

# Application Configuration
FIVEM_PLAYERS_JSON=your-players-json-url-here
FIVEM_INFO_JSON=your-info-json-url-here
CRON_SECRET= your-cron-secret-here
```

### Discord Bot Setup

1. Create a bot at [Discord Developer Portal](https://discord.com/developers/applications)
2. Enable required intents:
   - Server Members Intent
   - Presence Intent
   - Message Content Intent
3. Invite bot to your server with Administrator permissions
4. Copy bot token to `.env.local`

### Discord OAuth Setup

1. In Discord Developer Portal, go to OAuth2
2. Add redirect URL: `http://localhost:3000/api/auth/callback/discord`
3. Copy Client ID and Secret to `.env.local`

### Role Configuration

1. Go to your Discord server settings
2. Copy role IDs for Admin, Moderator, and Reviewer roles
3. Add to `.env.local`

### Application Types

Configure custom application types in `/admin/application-types`:
- Set application names (e.g., "Staff Application", "Whitelist")
- Configure cooldown periods
- Set unique approval rules
- Allow/disallow multiple pending applications
- Create custom form fields

## 📱 Usage

### For Users

1. **Sign in with Discord** using the button in the header
2. **Submit Application**:
   - Click "Apply" in navigation
   - Select application type
   - Fill out the form
   - Submit for review
3. **Track Applications**:
   - View status in "My Applications"
   - Receive notifications for status changes
4. **Create Support Tickets**:
   - Go to Support page
   - Fill out ticket form with category and priority
   - Track ticket status and replies

### For Staff

1. **Access Admin Panel** via "Admin Panel" button (visible to staff)
2. **Review Applications**:
   - View all pending applications
   - Filter and sort by priority/date
   - Add internal notes
   - Approve or deny with optional messages
   - Assign to other staff members
3. **Manage Tickets**:
   - View all support tickets
   - Update status and priority
   - Reply to tickets
   - Close resolved tickets
4. **User Management**:
   - Ban or blacklist users
   - View user application history
5. **Configuration**:
   - Manage announcements
   - Update server rules
   - Create application types
   - Configure shop products

## 🎨 Customization

### Theming
- Edit `tailwind.config.ts` for color schemes
- Modify `src/app/globals.css` for global styles
- Update theme provider in `src/app/components/theme-provider.tsx`

### Branding
- Replace logo in `/public/images/`
- Update server name in `.env.local`
- Customize colors in Tailwind config

### Application Fields
- Create custom field types in application type manager
- Support for text, textarea, number, select, and checkbox
- Required/optional field configuration

## 🔐 Permissions System

### Role Hierarchy
1. **Admin**: Full access to all features
2. **Moderator**: Application management, ticket management, user management
3. **Reviewer**: Application review only (read-only for other features)
4. **User**: Submit applications and tickets

### Permission Matrix
| Feature | Admin | Moderator | Reviewer | User |
|---------|-------|-----------|----------|------|
| Submit Application | ✅ | ✅ | ✅ | ✅ |
| Review Applications | ✅ | ✅ | ✅ | ❌ |
| Manage Tickets | ✅ | ✅ | ❌ | ❌ |
| Ban Users | ✅ | ✅ | ❌ | ❌ |
| Manage Announcements | ✅ | ❌ | ❌ | ❌ |
| Edit Rules | ✅ | ❌ | ❌ | ❌ |
| View Activity Log | ✅ | ✅ | ❌ | ❌ |
| Manage Shop | ✅ | ❌ | ❌ | ❌ |

## 📊 Data Structure

Data is stored in JSON files in the `/data` directory:
- `applications.json` - All applications
- `application_drafts.json` - Draft applications
- `archived_applications.json` - Archived applications
- `application-types.json` - Application type configurations
- `tickets.json` - Support tickets
- `bans.json` - Banned users
- `blacklist.json` - Blacklisted users
- `notifications.json` - System notifications
- `announcements.json` - Server announcements
- `rules.json` - Server rules
- `shop-products.json` - Shop products
- `activity_log.json` - Complete audit trail

## 🐛 Troubleshooting

### Discord Bot Not Responding
- Verify bot token in `.env.local`
- Check bot is in your server
- Ensure required intents are enabled
- Verify DISCORD_GUILD_ID matches your server

### Authentication Issues
- Clear browser cookies
- Verify Discord OAuth redirect URL
- Check NEXTAUTH_URL matches your domain
- Regenerate NEXTAUTH_SECRET

### Data Not Persisting
- Ensure `/data` directory exists and is writable
- Check file permissions
- Verify no file locking issues

### Application Errors
- Clear `.next` directory and rebuild: `rm -rf .next && npm run dev`
- Check console for specific error messages
- Verify all environment variables are set

## 🚀 Deployment

### Vercel (Recommended)
1. Push code to GitHub
2. Import project in Vercel
3. Add environment variables
4. Deploy

### Self-Hosted
```bash
npm run build
npm start
```

### Docker
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

## 🔄 Migration to Database

To migrate from JSON files to a database:

1. Install database adapter (e.g., Prisma, MongoDB)
2. Create schemas matching JSON structures
3. Write migration scripts to import JSON data
4. Update API routes to use database queries
5. Update activity log and notification systems

Example structure already supports easy migration due to well-defined TypeScript interfaces.

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🗺️ Roadmap

- [ ] Database migration (PostgreSQL/MongoDB)
- [ ] Real-time updates with WebSockets
- [ ] Advanced analytics dashboard
- [ ] Mobile app (React Native)
- [ ] Multi-language support
- [ ] Advanced search with Elasticsearch
- [ ] File upload support for applications
- [ ] Interview scheduling system
- [ ] Automated application scoring
- [ ] Integration with more payment providers

## 📞 Support

For support, join our [Discord support server](https://discord.gg/663eBMPWPB) or open an issue on GitHub.

## 🙏 Acknowledgments

- Original project: [Aura Applications](https://github.com/auradevelopment5m/aura-applications) by Aura Development
- Next.js team for the amazing framework
- Vercel for hosting platform
- Radix UI for accessible components
- Tailwind CSS for styling system
- Discord for API and OAuth

---

**Made with ❤️ for FiveM Roleplay Communities**
