module LN.View.Boards.Show (
  renderView_Boards_Show,
  renderView_Boards_Show'
) where



import Daimyo.Data.ArrayList           (listToArray)
import Data.Map                        as M
import Data.Maybe                      (Maybe(..), maybe)
import Halogen                         (ComponentHTML)
import Halogen.HTML.Indexed            as H
import Halogen.HTML.Properties.Indexed as P
import Halogen.Themes.Bootstrap3       as B
import Optic.Core                      ((^.), (..))
import Prelude                         (id, show, map, negate, ($), (<>))

import LN.Input.Types                  (Input)
import LN.Router.Link                  (linkToP, linkToP_Classes, linkToP_Glyph')
import LN.Router.Types                 (Routes(..), CRUD(..))
import LN.State.Types                  (State)
import LN.View.Module.Loading          (renderLoading)
import LN.T                            ( Param(..)
                                       , OrganizationPackResponse, ForumPackResponse
                                       , _OrganizationPackResponse, _OrganizationResponse, organization_
                                       , _ForumPackResponse, _ForumResponse, forum_
                                       , _BoardPackResponse, _BoardResponse, board_
                                       , _BoardStatResponse, stat_
                                       , ThreadResponse(..)
                                       , ThreadPostResponse(..)
                                       , UserSanitizedResponse(..)
                                       , latestThread_, latestThreadPost_, latestThreadPostUser_)




renderView_Boards_Show :: State -> ComponentHTML Input
renderView_Boards_Show st =

  case st.currentOrganization, st.currentForum of
       Just org_pack, Just forum_pack -> renderView_Boards_Show' org_pack forum_pack st
       _, _                           -> renderLoading



renderView_Boards_Show' :: OrganizationPackResponse -> ForumPackResponse -> State -> ComponentHTML Input
renderView_Boards_Show' org_pack forum_pack st =
  H.ul [P.class_ B.listUnstyled] $
    map (\pack ->
      let
        board_pack = pack ^. _BoardPackResponse
        board      = pack ^. _BoardPackResponse .. board_ ^. _BoardResponse
        stat       = pack ^. _BoardPackResponse .. stat_ ^. _BoardStatResponse
        thread     = pack ^. _BoardPackResponse .. latestThread_
        post       = pack ^. _BoardPackResponse .. latestThreadPost_
        user       = pack ^. _BoardPackResponse .. latestThreadPostUser_
      in
      H.li_ [
        H.div [P.class_ B.row] [
            H.div [P.class_ B.colXs1] [
              H.p_ [H.text "icon"],
              H.div [P.class_ B.container] [
                H.div_ [linkToP [] (OrganizationsForumsBoards org.name forum.name (Edit board.name) []) "edit"],
                H.div_ [linkToP [] (OrganizationsForumsBoards org.name forum.name New []) "new-board"],
                H.div_ [linkToP [] (OrganizationsForumsBoards org.name forum.name (Delete board.name) []) "delete-board"]
              ]
            ]
          , H.div [P.class_ B.colXs5] [
                H.div [P.class_ B.listGroup] [linkToP_Classes [B.listGroupItem] [] (OrganizationsForumsBoards org.name forum.name (Show $ board.name) []) board.displayName]
              , H.p_ [H.text $ maybe "No description." id board.description]
            ]
          , H.div [P.class_ B.colXs1] [
              H.p_ [H.text $ show stat.threads <> " threads"]
            ]
          , H.div [P.class_ B.colXs1] [
              H.p_ [H.text $ show stat.threadPosts <> " posts"]
            ]
          , H.div [P.class_ B.colXs1] [
              H.p_ [H.text $ show stat.views <> " views"]
            ]
          , H.div [P.class_ B.colXs3] [
              case thread, post, user of
                   Just (ThreadResponse thread'), Just (ThreadPostResponse post'), Just (UserSanitizedResponse user') ->
                    H.div_ [
                      H.p_ [H.text $ "Last post by ", linkToP [] (Users (Show user'.nick) []) user'.nick],
                      H.p_ [H.text $ "in ", linkToP [Offset (-1)] (OrganizationsForumsBoardsThreads org.name forum.name board.name (Show thread'.name) []) thread'.name],
                      H.p_ [H.text $ show post'.createdAt]
                    ]
                   _, _, _ ->
                    H.div_ [
                      H.p_ [H.text "No posts."]
                    ]
          ]
        ]
      ])
    $ listToArray $ M.values st.boards
  where
  org   = org_pack ^. _OrganizationPackResponse .. organization_ ^. _OrganizationResponse
  forum = forum_pack ^. _ForumPackResponse .. forum_ ^. _ForumResponse
