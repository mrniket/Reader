/*
 ******************************************************************************
 * Copyright (C) 2014-2017 Elsevier/Mendeley.
 *
 * This file is part of the Mendeley iOS SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *****************************************************************************
 */

#import "MendeleyObjectAPI.h"

@interface MendeleyProfilesAPI : MendeleyObjectAPI
/**
   @name MendeleyProfilesAPI
   This class provides access methods to the REST profiles API
   All of the methods are accessed via MendeleyKit.
   Developers should use the methods provided in MendeleyKit rather
   than the methods listed here.
 */
/**
   Pulls the users profile
   @param task
   @param completionBlock
 */
- (void)pullMyProfileWithTask:(MendeleyTask *)task
              completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

/**
   Pulls the profile of a user with a given ID
   @param profileID
   @param task
   @param completionBlock
 */
- (void)pullProfile:(NSString *)profileID
               task:(MendeleyTask *)task
    completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

/**
   Obtains a profile icon for a specified MendeleyProfile and icon type (maybe standard, square, original)
   @param profile
   @param iconType
   @param task
   @param completionBlock returning the image data as NSData
 */
- (void)profileIconForProfile:(MendeleyProfile *)profile
                     iconType:(MendeleyIconType)iconType
                         task:(MendeleyTask *)task
              completionBlock:(MendeleyBinaryDataCompletionBlock)completionBlock;


/**
   Obtains a profile icon based on the given link URL string
   @param iconURLString
   @param task
   @param completionBlock returning the image data as NSData
 */
- (void)profileIconForIconURLString:(NSString *)iconURLString
                               task:(MendeleyTask *)task
                    completionBlock:(MendeleyBinaryDataCompletionBlock)completionBlock;

/**
   Creates a new profile based on the MendeleyNewProfile argument passed in. The following properties MUST be
   provided to be able to create a new profile
   first_name, last_name, email, password, main discipline, academic status
   Note: the email MUST be unique
   @param profile - containing at least the 6 mandatory properties given above
   @param task
   @param completionBlock - the completionHandler.
 */
- (void)createProfile:(MendeleyNewProfile *)profile
                 task:(MendeleyTask *)task
      completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

/**
   Updates an existing user's profile based on the MendeleyAmendmentProfile argument passed in.
   If the user wants to update his password the following properties must be provided
   - password (i.e. the new password)
   - old_password (i.e the previous password to be replaced)
   @param profile - the profile containing the updated parameters.
   @param task
   @param completionBlock - the completionHandler.
 */
- (void)updateMyProfile:(MendeleyAmendmentProfile *)myProfile
                   task:(MendeleyTask *)task
        completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

@end
