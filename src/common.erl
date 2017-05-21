-module(common).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").
-include("db.hrl").
-include("records.hrl").

%% CMS Module interface {{{1
functions() -> % {{{2
    [
     %{parallel_block, "Parallell Group of Blocks"},
     %{waterfall, "Waterfall Block"},
     {asset, "Static Asset"},
     {template, "Template"},
     %{list, "Items List"},
     %{list_item, "List Item"},
     {link_url, "Link"},
     %{icon, "Icon"},
     %{script, "Inline Script"},
     {text, "Text with HTML"}
     %{full_block, "One Column Row"}
     ].

format_block(link_url, [Block, URL]) -> % {{{2
    wf:f("Link: ~s(href=~s)", [Block, URL]);
format_block(text, [Text]) -> % {{{2
    #panel{body=Text};
format_block(template, [TID]) -> % {{{2
    [#cms_template{name=Name}] = db:get_template(TID),
    wf:f("Template: ~s(~p)", [Name, TID]);
format_block(asset, [AID]) -> % {{{2
    [#cms_asset{type=Type, file=File, name=Name}|_] = db:get_asset(AID),
    wf:f("Asset ~s: ~s(~p)", [Type, Name, File]);
format_block(F, A) -> % {{{2
    wf:f("common:~s(~p)", [F, A]).

form_data(link_url, A) -> % {{{2
    [_, Block, URL, Classes] = admin:maybe_empty(A, 4),
    {[
      {"URL",
       #txtbx{
          id=url,
          text=URL,
          placeholder="http://yoursite.com"
         }}
     ],
     [], Block, Classes};
form_data(text, A) -> % {{{2
    [_, Text] = admin:maybe_empty(A, 2),
    [
     #wysiwyg{class=["form-control"],
              id=text,
              html=Text,
              buttons=[
                       #panel{
                          class="btn-group",
                          body=[
                                #wysiwyg_button{body="B",
                                                func="bold",
                                                class=["btn", "btn-default"]},
                                #wysiwyg_button{body="<i>I</i>",
                                                func="italic",
                                                class=["btn", "btn-default"]},
                                #wysiwyg_button{body="<u>U</u>",
                                                func="underline",
                                                class=["btn", "btn-default"]},
                                #wysiwyg_button{body="<s>S</s>",
                                                func="strikethrough",
                                                class=["btn", "btn-default"]}
                               ]},
                       #panel{
                          class="btn-group",
                          body=[
                                #wysiwyg_button{
                                   body="<i class='fa fa-align-left'></i>",
                                   func="justifyleft",
                                   class=["btn", "btn-default"]},
                                #wysiwyg_button{
                                   body="<i class='fa fa-align-center'></i>",
                                   func="justifycenter",
                                   class=["btn", "btn-default"]},
                                #wysiwyg_button{
                                   body="<i class='fa fa-align-right'></i>",
                                   func="justifyright",
                                   class=["btn", "btn-default"]},
                                #wysiwyg_button{
                                   body="<i class='fa fa-align-justify'></i>",
                                   func="justifyfull",
                                   class=["btn", "btn-default"]}
                               ]},
                       #panel{
                          class="btn-group",
                          body=[
                                #wysiwyg_button{
                                   body="<i class='fa fa-undo'></i>",
                                   func="undo",
                                   class=["btn", "btn-default"]},
                                #wysiwyg_button{
                                   body="<i class='fa fa-repeat'></i>",
                                   func="redo",
                                   class=["btn", "btn-default"]},
                                #wysiwyg_button{
                                   body="<i class='fa fa-close'></i>",
                                   func="removeFormat",
                                   class=["btn", "btn-default"]}
                               ]},
                       #panel{
                          class="btn-group",
                          body=[
                                #wysiwyg_button{
                                   body="<i class='fa fa-list-ol'></i>",
                                   func="insertorderedlist",
                                   class=["btn", "btn-default"]},
                                #wysiwyg_button{
                                   body="<i class='fa fa-list-ul'></i>",
                                   func="insertunorderedlist",
                                   class=["btn", "btn-default"]},
                                #wysiwyg_button{
                                   body="<i class='fa fa-outdent'></i>",
                                   func="outdent",
                                   class=["btn", "btn-default"]},
                                #wysiwyg_button{
                                   body="<i class='fa fa-indent'></i>",
                                   func="indent",
                                   class=["btn", "btn-default"]}
                               ]},
                       #panel{
                          class="btn-group",
                          body=[
                                #link{
                                   class=[
                                          "btn",
                                          "btn-default",
                                          "dropdown-toggle"
                                         ],
                                   text="H<i class='caret'></i>",
                                   data_fields=[
                                                {toggle, dropdown}
                                               ]},
                                #list{
                                   class="dropdown-menu",
                                   numbered=flase,
                                   body=[ 
                                         #listitem{
                                            body=
                                            #wysiwyg_button{
                                            body="H1",
                                            func="heading h1",
                                            class=["btn", "btn-default"]}
                                           },
                                         #listitem{
                                            body=
                                         #wysiwyg_button{
                                            body="H2",
                                            func="heading 2",
                                            class=["btn", "btn-default"]}
                                           },
                                         #listitem{
                                            body=
                                         #wysiwyg_button{
                                            body="H3",
                                            func="heading 3",
                                            class=["btn", "btn-default"]}
                                           },
                                         #listitem{
                                            body=
                                         #wysiwyg_button{
                                            body="H4",
                                            func="heading 4",
                                            class=["btn", "btn-default"]}}
                                        ]}
                               ]}
                      ]}
    ];
form_data(template, A) -> % {{{2
    [_, TID] = admin:maybe_empty(A, 2),
    Templates = db:get_templates(),
    DropdDown = [ {Path, Name} || #{file := Path, name := Name} <- Templates],
    [
     #span{text="Template"},
     #dd{
        id=template,
        value=TID,
        options=DropdDown
       }
    ];
form_data(asset, A) -> % {{{2
    wf:info("Asset: ~p", [A]),
    [_, AID] = admin:maybe_empty(A, 2),
    Type = case db:get_asset(AID) of
               [] -> binary;
               [#cms_asset{type=T}|_] -> T
           end,

    [
     #span{text="Asset Type"},
     #dd{
        id=asset_type,
        value=Type,
        postback={asset, type, change},
        delegate=?MODULE,
        options=asset_types()
       },

     #span{text="Asset"},
     assets_dropdown(Type, AID)
    ];
form_data(F, A) -> % {{{2
    {[], []}.

save_block(#cms_mfa{mfa={common, link_url, [Block, URL, Classes]}}=Rec) -> % {{{2
    Rec#cms_mfa{mfa={common, link_url, [Block, URL, Classes]}};
save_block(#cms_mfa{mfa={common, text, [_Block, _Classes]}}=Rec) -> % {{{2
    HTML = q(text, ""),
    Rec#cms_mfa{mfa={common, text, [HTML]}};
save_block(#cms_mfa{mfa={common, asset, [_Block, _Type, StringId, _Classes]}}=Rec) -> % {{{2
    Id = string:tokens(StringId, "."),
    Rec#cms_mfa{mfa={common, asset, [Id]}};
save_block(#cms_mfa{mfa={common, template, [_Block, File, _Classes]}}=Rec) -> % {{{2
    Rec#cms_mfa{mfa={common, template, [File]}}.

%% Block renderers {{{1
parallel_block(#cms_page{id = PID} = Page, Block) -> % {{{2
    Functions = db:get_mfa(PID, Block),
    lists:map(fun(#cms_mfa{mfa={M, F, Args}}) ->
                        apply(M, F, [Page | Args]);
                   (#cms_mfa{mfa=Fun}) when is_function(Fun) ->
                                    Fun(Page)
                end, 
                Functions).

waterfall(#cms_page{id = PID} = Page, Block) -> % {{{2
    Functions = db:get_mfa(PID, Block),
    wf:info("Waterfall: ~p", [Functions]),
    lists:foldl(fun(#cms_mfa{mfa={M, F, Args}}, P) ->
                        apply(M, F, [P | Args]);
                   (#cms_mfa{mfa=Fun}, P) when is_function(Fun) ->
                                    Fun(P)
                end, 
                Page,
                Functions).

asset(_Page, AID) -> % {{{1 % {{{2
    Assets = db:get_asset(AID),
    Debug = application:get_env(nitrogen, debug, false),
    #cms_asset{file=Path,
               type=Type} = case {length(Assets), Debug} of
                                {1, _} -> hd(Assets);
                                {L, Debug} when L > 1 ->
                                    hd([A || A <- Assets,
                                             A#cms_asset.minified == not Debug]);
                                    _ -> #cms_asset{type=none}
                                       end,
    case Type of
        script ->
            "<script src='" ++ wf:to_list(Path) ++ "' type='text/javascript' charset='utf-8'></script>";
        css ->
            "<link href='" ++ wf:to_list(Path) ++ "' rel='stylesheet'>";
        image ->
            #image{image=wf:to_list(Path)};
        _ -> []
    end.


template(#cms_page{id=PID}=Page, TID) -> % {{{2
    template(#cms_page{id=PID}=Page, TID, []).

template(#cms_page{id=PID}=Page, TID, AdditionalBindings) -> % {{{2
    wf:info("Page for template: ~p, TID: ~p", [Page, TID]),
    [#cms_template{file=File,
                   bindings=Bindings}] = db:get_template(TID),

    #template{file=File,
              bindings=[{'Page', Page} | Bindings ++ AdditionalBindings]}.

list(Page, Block, Classes) -> % {{{2
    Items = parallel_block(Page, Block),
    #list{body=Items, class=Classes, html_id=Block}.

list_item(Page, ItemID) -> % {{{2
    %<li>
    %<a href="index.html"><i class="fa fa-dashboard fa-fw"></i> Dashboard</a>
    %</li>
    #listitem{body=parallel_block(Page, ItemID)}.

link_url(Page, Block, URL) -> % {{{2
    link_url(Page, Block, URL, []).

link_url(Page, Block, URL, Classes) -> % {{{2
    #link{
       url=URL, 
       class=Classes,
       body=parallel_block(Page, Block)
      }.

link_event(Page, Block, Event) -> % {{{2
    #link{
       actions=Event,
       body=parallel_block(Page, Block)
      }.

icon(_Page, Font, Name, Classes) -> % {{{2
    icon(Font, Name, Classes).

icon(Font, Name, Classes) -> % {{{2
    Cls = [Font, wf:f("~s-~s", [Font, Name]) | Classes],
    Class = string:join(Cls, " "),
    wf:f("<i class='~s'></i>", [Class]).

script(_Page, Script) -> % {{{2
    wf:wire(#script{script=Script}).

text(_Page, Text) -> % {{{2
    Text.

full_block(_Page, Body) -> % {{{2
    #bs_row{
       body=#bs_col{
               cols={lg, 12},
               body=Body}}.


%% Event handlers % {{{1
event({asset, type, change}) -> % {{{2
    AssetType = wf:to_atom(q(asset_type, "image")),
    wf:replace(asset_id, assets_dropdown(AssetType));

event(Ev) -> % {{{2
    wf:info("~p event ~p", [?MODULE, Ev]).

%% Helpers {{{1
private_block(Block) -> % {{{2
    wf:f("+~s", [Block]).

sub_block(Block, Sub) -> % {{{2
    wf:to_list(Block) ++ "/" ++ wf:to_list(Sub).

q(Id, Default) -> % {{{2
    case wf:q(Id) of
        "" ->
            Default;
        undefined ->
            Default;
        A -> A
    end.

%% Dropdown formatters {{{1
asset_types() -> % {{{2
    [{css, "CSS"},
     {script, "Script"},
     {image, "Image"},
     {binary, "Other"}].

assets_dropdown(AssetType) -> % {{{2
    assets_dropdown(AssetType, "").

assets_dropdown(AssetType, AID) -> % {{{2
    AssetsDup = db:get_assets(AssetType),
    Assets = sets:to_list(sets:from_list(AssetsDup)),
    Options = [ #option{value=string:join(Id, "."),
                        text=Name} || #{id := Id,
                                        name := Name} <- Assets],
     #dd{
        id=asset_id,
        value=string:join(AID, "."),
        options=Options
       }.
