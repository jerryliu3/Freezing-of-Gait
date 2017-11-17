//
//  Created by Yanyan Tran on 2017-11-17.
//  Copyright © 2017 Yanyan Tran. All rights reserved.
//

const int k = 3;
const int n = 25; // number of training points

int features[][n] = {
    {}, // feature 1
    {}, // feature 2
};

bool labels[] = {}; // labels

// Implements k-nearest-neighbours algorithm for the detection of freezing of gait
// pre: data contains the extracted feature
// post: 0 for not FoG, 1 for FoG
bool predict(int f1, int f2)
{
    int distances[n];
    
    // Calculate distances
    for (int i = 0; i < n; i++)
    {
        distances[i] = sqrt( pow(features[0][i]-f1,2) + pow(features[1][i]-f2,2) );
    }
    
    // Find index of closest three neighbours
    // --- loop through k times for kn run time & keep track of visited indices
    int visited[] = {-1, -1, -1}; // hard code
    int votes[] = {0,0};
    int maxi, maxind;
    for (int i = 0; i < k; i++)
    {
        maxi = 0;
        maxind = 0;
        for (int j = 0; j < n; j++)
        {
            if (distances[j] >= maxi)
            {
                if (j != visited[0] && j != visited[1] && j != visited[2])
                {
                    maxi = distances[j];
                    maxind = j;
                }
            }
        }
        visited[i] = maxind;
        votes[ labels[maxind] ] += 1;
    }
    
    return (votes[0] < votes[1]);
}

