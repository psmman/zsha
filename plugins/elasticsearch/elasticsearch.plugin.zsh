alias ech='GET _cluster/health'
alias ecs='GET _cluster/state'
alias ens='GET _nodes/stats'
alias esf='GET _stats/fielddata'

if [ -z ${CLIENT_ELK_NODE} ]; then
    export CLIENT_ELK_NODE=localhost
fi

# GET
if which json_reformat > /dev/null 2>&1; then 
    GET() { curl -s -XGET http://${CLIENT_ELK_NODE}:9200/"$@" | json_reformat 2>/dev/null || curl -s -XGET http://${CLIENT_ELK_NODE}:9200/"$@" }
else
    GET() { curl -s -XGET http://${CLIENT_ELK_NODE}:9200/"$@" }
fi

# HEAD
HEAD() { curl -s -XHEAD -i http://${CLIENT_ELK_NODE}:9200/"$@" }

# DELETE
DELETE() { curl -s -XDELETE http://${CLIENT_ELK_NODE}:9200/"$@" }

# PUT
PUT() { curl -s -XPUT http://${CLIENT_ELK_NODE}:9200/"$@" }

# POST
POST() { curl -s -XPOST http://${CLIENT_ELK_NODE}:9200/"$@" }
