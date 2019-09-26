export const SAVE_COMMUNITY_INFO = 'SAVE_COMMUNITY_INFO'
export const SAVE_COMMUNITY_PRICE = 'SAVE_COMMUNITY_PRICE'
export const SAVE_COMMUNITY_CLIENT = 'SAVE_COMMUNITY_CLIENT'
export const FETCH_COMMUNITY = 'FETCH_COMMUNITY'

export const fetchCommunity = () => ({
  type: FETCH_COMMUNITY,
})

export const saveCommunityPrice = (tokenAddress, price) => ({
  type: SAVE_COMMUNITY_PRICE,
  tokenAddress,
  price,
})

export const saveCommunityInfo = (
  name,
  symbol,
  tokenAddress,
  organization,
  logo,
  banner,
  description,
  website,
  marketCap,
  price,
  totalSupply,
  last24HrsPrice,
  last24HrsTotalSupply,
  collateralEquation,
  tcds,
  tcr,
  parameterAddress,
) => ({
  type: SAVE_COMMUNITY_INFO,
  name,
  symbol,
  tokenAddress,
  organization,
  logo,
  banner,
  description,
  website,
  marketCap,
  price,
  totalSupply,
  last24HrsPrice,
  last24HrsTotalSupply,
  collateralEquation,
  tcds,
  tcr,
  parameterAddress,
})

export const saveCommunityClient = (address, client) => ({
  type: SAVE_COMMUNITY_CLIENT,
  address,
  client,
})
