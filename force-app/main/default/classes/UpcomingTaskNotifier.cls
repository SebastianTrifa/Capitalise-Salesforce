global class UpcomingTaskNotifier implements Schedulable {
    global void execute(SchedulableContext context) {
        Date cutoff = System.today() + 15;
        List<Task> upcomingTasks = [SELECT Id, WhatId, Status, Subject, ActivityDate, OwnerId, Owner.Name from Task where Status != 'Completed' and ActivityDate=:cutoff and Subject Like '%RE-ENGAGEMENT'];
        List<Task> dueTasks = [SELECT Id, WhatId, Status, Subject, ActivityDate, OwnerId, Owner.Name from Task where Status != 'Completed' and ActivityDate=TODAY and Subject Like '%RE-ENGAGEMENT'];
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        for(Task t : upcomingTasks) {

            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            mentionSegmentInput.id = t.OwnerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            textSegmentInput.text = t.Subject + ' Task upcoming!';
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = t.WhatId;
            
            ConnectApi.BatchInput input = new ConnectApi.BatchInput(feedItemInput);
            batchInputs.add(input);
        }

        for(Task t : dueTasks) {
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            mentionSegmentInput.id = t.OwnerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            textSegmentInput.text = t.Subject + ' Task now due!';
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = t.WhatId;
            
            ConnectApi.BatchInput input = new ConnectApi.BatchInput(feedItemInput);
            batchInputs.add(input);
        }

        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
    }
}