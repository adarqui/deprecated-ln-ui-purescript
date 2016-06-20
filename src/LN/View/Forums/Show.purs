module LN.View.Forums.Show (
  renderView_Forums_Show,
  renderView_Forums_Show'
) where



import LN.ArrayList           (listToArray)
import Data.Map                        as M
import Data.Maybe                      (Maybe(..), maybe)
import Halogen                         (ComponentHTML, HTML)
import Halogen.HTML.Indexed            as H
import Halogen.HTML.Properties.Indexed as P
import Halogen.Themes.Bootstrap3       as B
import Optic.Core                      ((^.), (..))
import Prelude                         (id, map, show, ($), (<>), (/=))

import LN.Input.Types                  (Input)
import LN.Router.Link                  (linkToP_Classes, linkToP_Glyph', linkToP)
import LN.Router.Types                 (Routes(..), CRUD(..))
import LN.Router.Class.Params          (emptyParams)
import LN.State.Types                  (State)
import LN.View.Helpers
import LN.View.Boards.Index            (renderView_Boards_Index')
import LN.View.Forums.LatestPosts      (renderView_Forums_LatestPosts')
import LN.View.Forums.MessagesOfTheWeek(renderView_Forums_MessagesOfTheWeek')
import LN.View.Module.Loading          (renderLoading)
import LN.T                            ( ForumPackResponse
                                       , _ForumPackResponse, _ForumResponse, organization_, isOwner_
                                       , _ForumPackResponse, _ForumResponse, forum_
                                       , OrganizationPackResponse, OrganizationResponse
                                       , _OrganizationPackResponse, _OrganizationResponse
                                       , organization_)




renderView_Forums_Show :: State -> ComponentHTML Input
renderView_Forums_Show st =

  case st.currentOrganization, st.currentForum of

       Just org_pack, Just forum_pack ->
         renderView_Forums_Show' org_pack forum_pack
           (renderView_Boards_Index' org_pack forum_pack st.boards)
           (renderView_Forums_LatestPosts' org_pack forum_pack)
           (renderView_Forums_MessagesOfTheWeek' org_pack forum_pack)

       _, _                           -> renderLoading



renderView_Forums_Show'
  :: OrganizationPackResponse
  -> ForumPackResponse
  -> HTML _ _
  -> HTML _ _
  -> HTML _ _
  -> ComponentHTML Input
renderView_Forums_Show'
  org_pack
  forum_pack
  plumbing_boards
  plumbing_latest_posts
  plumbing_messages_of_the_week
  =
  H.div [P.class_ B.containerFluid] [

    H.div [P.class_ B.pageHeader] [
      H.h2_ [H.text forum.name],
      H.p [P.class_ B.lead] [H.text forum_desc],

      if org_owner
         then
           buttonGroup_HorizontalSm1 [
             glyphButtonLinkDef_Pencil $ OrganizationsForums org.name (Edit forum.name) emptyParams,
             glyphButtonLinkDef_Plus $ OrganizationsForumsBoards org.name forum.name New emptyParams,
             glyphButtonLinkDef_Trash $ OrganizationsForums org.name (Delete forum.name) emptyParams
           ]
         else H.div_ []

    ],

    H.div [] [plumbing_boards],

    H.div [] [plumbing_latest_posts],

    H.div [] [plumbing_messages_of_the_week]

  ]
  where
  org        = org_pack ^. _OrganizationPackResponse .. organization_ ^. _OrganizationResponse
  org_owner  = org_pack ^. _OrganizationPackResponse .. isOwner_
  forum      = forum_pack ^. _ForumPackResponse .. forum_ ^. _ForumResponse
  forum_desc = maybe "No description." id forum.description
