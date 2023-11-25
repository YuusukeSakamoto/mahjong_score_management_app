
[1mFrom:[0m /home/ec2-user/environment/mahjong_score_management_app/app/views/match_groups/_result_table.html.haml:41 #<Class:0x00007ff7dd14a8e8>#_app_views_match_groups__result_table_html_haml__1486729110963126240_53040:

    [1;34m36[0m:                 - else
    [1;34m37[0m:                   = link_to edit_match_path(links[i][:id]), class: 'px-1 pb-0 text-main' do
    [1;34m38[0m:                     %i.fa-regular.fa-pen-to-square{style: "padding-top: 1px;"}
    [1;34m39[0m:               %td.p-0
    [1;34m40[0m:                 - binding.pry
 => [1;34m41[0m:                 = link_to match_path(links[i][:id]), 
    [1;34m42[0m:                   data: { confirm: "対局成績を削除しますか?"}, 
    [1;34m43[0m:                   method: :delete do
    [1;34m44[0m:                   %i.fa-regular.fa-trash-can
    [1;34m45[0m: 
    [1;34m46[0m:       %tfoot

