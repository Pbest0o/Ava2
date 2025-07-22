public with sharing class VideoPlatformController {
    
    @AuraEnabled(cacheable=true)
    public static List<Video__c> getVideos() {
        try {
            return [
                SELECT Id, Title__c, Description__c, Video_URL__c, Thumbnail_URL__c, 
                       View_Count__c, Like_Count__c, CreatedDate, CreatedBy.Name
                FROM Video__c
                WHERE Is_Active__c = true
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving videos: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void uploadVideo(String title, String description, String videoUrl) {
        try {
            Video__c newVideo = new Video__c(
                Title__c = title,
                Description__c = description,
                Video_URL__c = videoUrl,
                View_Count__c = 0,
                Like_Count__c = 0,
                Is_Active__c = true
            );
            insert newVideo;
        } catch (Exception e) {
            throw new AuraHandledException('Error uploading video: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void likeVideo(String videoId) {
        try {
            Video__c video = [SELECT Id, Like_Count__c FROM Video__c WHERE Id = :videoId LIMIT 1];
            if (video != null) {
                video.Like_Count__c = (video.Like_Count__c != null ? video.Like_Count__c : 0) + 1;
                update video;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error liking video: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void addComment(String videoId, String commentText) {
        try {
            Video_Comment__c newComment = new Video_Comment__c(
                Video__c = videoId,
                Comment_Text__c = commentText
            );
            insert newComment;
        } catch (Exception e) {
            throw new AuraHandledException('Error adding comment: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Video_Comment__c> getComments(String videoId) {
        try {
            return [
                SELECT Id, Comment_Text__c, CreatedDate, CreatedBy.Name
                FROM Video_Comment__c
                WHERE Video__c = :videoId
                ORDER BY CreatedDate ASC
                LIMIT 50
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving comments: ' + e.getMessage());
        }
    }
}
