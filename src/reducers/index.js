import { combineReducers } from 'redux-immutable'

import band from 'reducers/band'
import community from 'reducers/community'
import current from 'reducers/current'
import transaction from 'reducers/transaction'

export default combineReducers({ band, community, current, transaction })
