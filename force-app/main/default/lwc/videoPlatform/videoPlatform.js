import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVideos from '@salesforce/apex/VideoPlatformController.getVideos';
import uploadVideo from '@salesforce/apex/VideoPlatformController.uploadVideo';
import likeVideo from '@salesforce/apex/VideoPlatformController.likeVideo';
import addComment from '@salesforce/apex/VideoPlatformController.addComment';
import getComments from '@salesforce/apex/VideoPlatformController.getComments';

export default class VideoPlatform extends LightningElement {
    @track videos = [];
    @track selectedVideo = null;
    @track comments = [];
    @track newComment = '';
    @track isLoading = true;
    @track showUploadModal = false;
    @track uploadTitle = '';
    @track uploadDescription = '';
    @track uploadUrl = '';
    @track searchTerm = '';
    @track filteredVideos = [];

    connectedCallback() {
        this.loadVideos();
    }

    @wire(getVideos)
    wiredVideos({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.videos = data.map(video => ({
                ...video,
                thumbnailUrl: video.Thumbnail_URL__c || '/resource/videoThumbnailPlaceholder',
                viewCount: video.View_Count__c || 0,
                likeCount: video.Like_Count__c || 0,
                createdDate: new Date(video.CreatedDate).toLocaleDateString()
            }));
            this.filteredVideos = [...this.videos];
        } else if (error) {
            this.showToast('Error', 'Failed to load videos: ' + error.body.message, 'error');
        }
    }

    loadVideos() {
        this.isLoading = true;
        getVideos()
            .then(result => {
                this.videos = result.map(video => ({
                    ...video,
                    thumbnailUrl: video.Thumbnail_URL__c || '/resource/videoThumbnailPlaceholder',
                    viewCount: video.View_Count__c || 0,
                    likeCount: video.Like_Count__c || 0,
                    createdDate: new Date(video.CreatedDate).toLocaleDateString()
                }));
                this.filteredVideos = [...this.videos];
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', 'Failed to load videos: ' + error.body.message, 'error');
            });
    }

    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
        if (this.searchTerm) {
            this.filteredVideos = this.videos.filter(video => 
                video.Title__c.toLowerCase().includes(this.searchTerm) ||
                video.Description__c?.toLowerCase().includes(this.searchTerm)
            );
        } else {
            this.filteredVideos = [...this.videos];
        }
    }

    handleVideoSelect(event) {
        const videoId = event.currentTarget.dataset.id;
        this.selectedVideo = this.videos.find(video => video.Id === videoId);
        this.loadComments(videoId);
        
        // Increment view count (you would call an apex method here)
        this.incrementViewCount(videoId);
    }

    incrementViewCount(videoId) {
        // This would call an Apex method to increment view count
        const video = this.videos.find(v => v.Id === videoId);
        if (video) {
            video.viewCount += 1;
        }
    }

    handleLike() {
        if (this.selectedVideo) {
            likeVideo({ videoId: this.selectedVideo.Id })
                .then(() => {
                    this.selectedVideo.likeCount += 1;
                    this.showToast('Success', 'Video liked!', 'success');
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to like video: ' + error.body.message, 'error');
                });
        }
    }

    handleCommentChange(event) {
        this.newComment = event.target.value;
    }

    handleAddComment() {
        if (this.newComment.trim() && this.selectedVideo) {
            addComment({ 
                videoId: this.selectedVideo.Id, 
                commentText: this.newComment 
            })
                .then(() => {
                    this.newComment = '';
                    this.loadComments(this.selectedVideo.Id);
                    this.showToast('Success', 'Comment added!', 'success');
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to add comment: ' + error.body.message, 'error');
                });
        }
    }

    loadComments(videoId) {
        getComments({ videoId })
            .then(result => {
                this.comments = result.map(comment => ({
                    ...comment,
                    createdDate: new Date(comment.CreatedDate).toLocaleDateString()
                }));
            })
            .catch(error => {
                console.error('Failed to load comments:', error);
            });
    }

    handleUploadVideo() {
        this.showUploadModal = true;
    }

    handleCloseUpload() {
        this.showUploadModal = false;
        this.uploadTitle = '';
        this.uploadDescription = '';
        this.uploadUrl = '';
    }

    handleUploadSubmit() {
        if (this.uploadTitle && this.uploadUrl) {
            uploadVideo({
                title: this.uploadTitle,
                description: this.uploadDescription,
                videoUrl: this.uploadUrl
            })
                .then(() => {
                    this.handleCloseUpload();
                    this.loadVideos();
                    this.showToast('Success', 'Video uploaded successfully!', 'success');
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to upload video: ' + error.body.message, 'error');
                });
        } else {
            this.showToast('Error', 'Please fill in all required fields', 'error');
        }
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleBackToList() {
        this.selectedVideo = null;
        this.comments = [];
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    get hasVideos() {
        return this.filteredVideos && this.filteredVideos.length > 0;
    }

    get showVideoList() {
        return !this.selectedVideo;
    }

    get showVideoPlayer() {
        return this.selectedVideo !== null;
    }
}
