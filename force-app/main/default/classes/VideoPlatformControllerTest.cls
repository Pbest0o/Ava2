@isTest
public class VideoPlatformControllerTest {
    
    @TestSetup
    static void makeData(){
        // Create test video records
        List<Video__c> testVideos = new List<Video__c>();
        for(Integer i = 0; i < 5; i++){
            testVideos.add(new Video__c(
                Title__c = 'Test Video ' + i,
                Description__c = 'Test description for video ' + i,
                Video_URL__c = 'https://example.com/video' + i + '.mp4',
                View_Count__c = i * 10,
                Like_Count__c = i * 5,
                Is_Active__c = true
            ));
        }
        insert testVideos;
        
        // Create test comments
        Video_Comment__c testComment = new Video_Comment__c(
            Video__c = testVideos[0].Id,
            Comment_Text__c = 'This is a test comment'
        );
        insert testComment;
    }
    
    @isTest
    static void testGetVideos() {
        Test.startTest();
        List<Video__c> videos = VideoPlatformController.getVideos();
        Test.stopTest();
        
        System.assertEquals(5, videos.size(), 'Should return 5 test videos');
        System.assertEquals('Test Video 4', videos[0].Title__c, 'Videos should be ordered by CreatedDate DESC');
    }
    
    @isTest
    static void testUploadVideo() {
        Test.startTest();
        VideoPlatformController.uploadVideo('New Test Video', 'New test description', 'https://example.com/newvideo.mp4');
        Test.stopTest();
        
        List<Video__c> videos = [SELECT Id, Title__c, Description__c, Video_URL__c FROM Video__c WHERE Title__c = 'New Test Video'];
        System.assertEquals(1, videos.size(), 'Should create one new video');
        System.assertEquals('New test description', videos[0].Description__c, 'Description should match');
    }
    
    @isTest
    static void testLikeVideo() {
        Video__c testVideo = [SELECT Id, Like_Count__c FROM Video__c LIMIT 1];
        Decimal originalLikeCount = testVideo.Like_Count__c;
        
        Test.startTest();
        VideoPlatformController.likeVideo(testVideo.Id);
        Test.stopTest();
        
        testVideo = [SELECT Id, Like_Count__c FROM Video__c WHERE Id = :testVideo.Id];
        System.assertEquals(originalLikeCount + 1, testVideo.Like_Count__c, 'Like count should be incremented by 1');
    }
    
    @isTest
    static void testAddComment() {
        Video__c testVideo = [SELECT Id FROM Video__c LIMIT 1];
        
        Test.startTest();
        VideoPlatformController.addComment(testVideo.Id, 'This is a new test comment');
        Test.stopTest();
        
        List<Video_Comment__c> comments = [SELECT Id, Comment_Text__c FROM Video_Comment__c WHERE Video__c = :testVideo.Id];
        System.assertEquals(2, comments.size(), 'Should have 2 comments (1 from setup + 1 new)');
        
        Boolean foundNewComment = false;
        for(Video_Comment__c comment : comments) {
            if(comment.Comment_Text__c == 'This is a new test comment') {
                foundNewComment = true;
                break;
            }
        }
        System.assert(foundNewComment, 'Should find the new comment');
    }
    
    @isTest
    static void testGetComments() {
        Video__c testVideo = [SELECT Id FROM Video__c LIMIT 1];
        
        Test.startTest();
        List<Video_Comment__c> comments = VideoPlatformController.getComments(testVideo.Id);
        Test.stopTest();
        
        System.assertEquals(1, comments.size(), 'Should return 1 comment from test setup');
        System.assertEquals('This is a test comment', comments[0].Comment_Text__c, 'Comment text should match');
    }
    
    @isTest
    static void testGetVideosException() {
        // Create a scenario that might cause an exception (this is a simplified example)
        try {
            Test.startTest();
            // Force an exception by deleting all videos and then trying to access them in an invalid way
            delete [SELECT Id FROM Video__c];
            List<Video__c> videos = VideoPlatformController.getVideos();
            Test.stopTest();
            
            // This should work fine even with no videos
            System.assertEquals(0, videos.size(), 'Should return empty list when no videos exist');
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception: ' + e.getMessage());
        }
    }
    
    @isTest
    static void testUploadVideoException() {
        try {
            Test.startTest();
            // Try to upload video with invalid data (null title)
            VideoPlatformController.uploadVideo(null, 'Description', 'https://example.com/video.mp4');
            Test.stopTest();
            System.assert(false, 'Should have thrown an exception for null title');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error uploading video'), 'Should throw AuraHandledException');
        }
    }
}
