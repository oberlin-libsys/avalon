/* 
 * Copyright 2011-2024, The Trustees of Indiana University and Northwestern
 *   University.  Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 * 
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software distributed
 *   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 *   CONDITIONS OF ANY KIND, either express or implied. See the License for the
 *   specific language governing permissions and limitations under the License.
 * ---  END LICENSE_HEADER BLOCK  ---
*/

import React from 'react';
import { render } from 'react-dom';
import CollectionList from './CollectionList';

const props = {
  baseUrl: 'https://spruce.dlib.indiana.edu/collections.json'
  // filter: 'Good Morning Dave'
};

render(<CollectionList {...props} />, document.getElementById('root'));
