trigger EventOpportunityAssignment on opportunityAssignment__e (after insert) {
    EventAssigmentController.updateOpportunities();
}