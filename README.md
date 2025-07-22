# Salesforce Video Platform LWC

A comprehensive Lightning Web Component (LWC) video platform designed for Salesforce Community users. This platform provides a YouTube-like experience for community members to upload, view, like, and comment on videos.

## Features

### Video Management
- **Video Upload**: Community users can upload videos with title, description, and video URL
- **Video Viewing**: Full-featured video player with playback controls
- **Video Search**: Real-time search functionality across video titles and descriptions
- **Video Statistics**: Track view counts and like counts for each video

### User Interactions
- **Like System**: Users can like videos with instant feedback
- **Comments**: Full commenting system with threaded discussions
- **Responsive Design**: Works seamlessly on desktop and mobile devices

### Modern UI/UX
- **Beautiful Design**: Modern, clean interface inspired by popular video platforms
- **Responsive Grid**: Adaptive video grid that works on all screen sizes
- **Smooth Animations**: Hover effects and smooth transitions
- **Loading States**: Proper loading indicators for better user experience

## Architecture

### Components
- **videoPlatform**: Main LWC component containing all functionality
- **VideoPlatformController**: Apex controller handling backend operations
- **Video__c**: Custom object for storing video information
- **Video_Comment__c**: Custom object for storing video comments

### Custom Objects

#### Video__c
- Title__c (Text) - Video title
- Description__c (Long Text Area) - Video description
- Video_URL__c (URL) - Direct link to video file
- Thumbnail_URL__c (URL) - Video thumbnail image
- View_Count__c (Number) - Number of views
- Like_Count__c (Number) - Number of likes
- Is_Active__c (Checkbox) - Whether video is active/published

#### Video_Comment__c
- Video__c (Lookup to Video__c) - Associated video
- Comment_Text__c (Long Text Area) - Comment content

### Apex Methods
- `getVideos()` - Retrieve all active videos
- `uploadVideo()` - Create new video record
- `likeVideo()` - Increment like count
- `addComment()` - Add new comment
- `getComments()` - Retrieve comments for a video

## Installation

1. Deploy the metadata to your Salesforce org:
   ```bash
   sfdx force:source:deploy -p force-app/main/default
   ```

2. Assign appropriate permissions to the custom objects and fields

3. Add the component to your Community pages:
   - Go to Community Builder
   - Add the "videoPlatform" component to any page
   - The component is available for Lightning App Pages, Home Pages, and Community Pages

## Usage

### For End Users
1. **Browse Videos**: View the video grid on the main page
2. **Search**: Use the search bar to find specific videos
3. **Watch Videos**: Click on any video to open the full player
4. **Interact**: Like videos and add comments
5. **Upload**: Use the "Upload Video" button to share new content

### For Administrators
1. **Content Moderation**: Use the Is_Active__c field to control video visibility
2. **Analytics**: Monitor view counts and engagement through reports
3. **Permissions**: Configure object-level and field-level security as needed

## Customization

### Styling
The component uses SLDS (Salesforce Lightning Design System) along with custom CSS. You can modify the styling in `videoPlatform.css`.

### Functionality
- Add video categories or tags
- Implement video approval workflows
- Add user subscriptions
- Integrate with external video hosting services
- Add video analytics and reporting

### Security
- Configure sharing rules for the Video__c object
- Set up field-level security
- Implement community-specific access controls

## Technical Notes

### Video Hosting
This component expects videos to be hosted externally (YouTube, Vimeo, AWS S3, etc.) and uses URLs to reference them. For production use, consider:
- CDN integration for better performance
- Video transcoding for multiple formats
- Secure video storage and access controls

### Performance
- Uses `@wire` decorator for efficient data loading
- Implements caching where appropriate
- Limits query results to prevent performance issues

### Browser Compatibility
- Supports all modern browsers
- Uses HTML5 video element for playback
- Responsive design works on mobile devices

## Future Enhancements

- Video playlist functionality
- User subscriptions and notifications
- Advanced search with filters
- Video analytics dashboard
- Integration with Salesforce Files
- Video streaming capabilities
- Live streaming support

## Support

For issues or feature requests, please check the Salesforce documentation for Lightning Web Components and Community Cloud.
