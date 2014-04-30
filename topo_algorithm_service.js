// Generated by CoffeeScript 1.6.3
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  angular.module("topo", []).factory("d3", [
    function() {
      return d3;
    }
  ]).factory("topoAlgorithm", [
    "d3", function(d3) {
      return {
        preProcess: function(raw, cb) {
          var add_to_linkset, blkports, d, enhanced_equlink, final, find_dup_n, find_linkidx, find_node_idx, glinks, gnodes, grings, i, l, link, linkidx, links, mring, n, n0, n1, node, omit_dup, p, r, rid, ring, rlinkidx, rnode, upports, _fn, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _len6, _len7, _len8, _m, _n, _o, _p, _q, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
          grings = {};
          gnodes = [];
          glinks = [];
          find_node_idx = function(mac) {
            var i, node, _i, _len;
            for (i = _i = 0, _len = gnodes.length; _i < _len; i = ++_i) {
              node = gnodes[i];
              if (node.mac === mac) {
                return i;
              }
            }
            return -1;
          };
          add_to_linkset = function(linkset, link) {
            var duplinks, l;
            duplinks = (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = linkset.length; _i < _len; _i++) {
                l = linkset[_i];
                if (enhanced_equlink(link, l)) {
                  _results.push(l);
                }
              }
              return _results;
            })();
            if (duplinks.length === 0) {
              return linkset.push(link);
            }
          };
          n0 = -1;
          n1 = -1;
          omit_dup = function(linkset) {
            var j, _i, _len, _results;
            if ((linkset != null) && linkset !== []) {
              _results = [];
              for (_i = 0, _len = linkset.length; _i < _len; _i++) {
                j = linkset[_i];
                _results.push((function(j) {
                  var n;
                  if ((j != null) && (j.nodepair != null) && j.blocked === false) {
                    if ((j.nodepair[0] === n0 && j.nodepair[1] === n1) || (j.nodepair[0] === n1 && j.nodepair[1] === n0) === true) {
                      n = linkset.indexOf(j);
                      linkset.splice(n, 1);
                      return console.log('duplicated data of link is deleted');
                    }
                  }
                })(j));
              }
              return _results;
            }
          };
          find_dup_n = function(linkset) {
            var i, _i, _len, _results;
            if ((linkset != null) && linkset !== []) {
              _results = [];
              for (_i = 0, _len = linkset.length; _i < _len; _i++) {
                i = linkset[_i];
                _results.push((function(i) {
                  if ((i != null) && (i.blocked != null) && i.blocked === true) {
                    n0 = i.nodepair[0];
                    n1 = i.nodepair[1];
                    return omit_dup(linkset);
                  }
                })(i));
              }
              return _results;
            }
          };
          find_linkidx = function(mac, pno) {
            var i, l, nidx, _i, _len;
            nidx = find_node_idx(mac);
            for (i = _i = 0, _len = glinks.length; _i < _len; i = ++_i) {
              l = glinks[i];
              if ((nidx === l.nodepair[0] && pno === l.portpair[0]) || (nidx === l.nodepair[1] && pno === l.portpair[1])) {
                return i;
              }
            }
          };
          enhanced_equlink = function(lka, lkb) {
            return (lka.nodepair[0] === lkb.nodepair[0] && lka.nodepair[1] === lkb.nodepair[1] && lka.blocked === lkb.blocked) || (lka.nodepair[0] === lkb.nodepair[1] && lka.nodepair[1] === lkb.nodepair[0] && lka.blocked === lkb.blocked);
          };
          _fn = function(d) {
            var o;
            if (d.node != null) {
              o = {
                mac: d.node.local_id,
                ip: d.node.local_ip_address,
                location: d.node.sys_location,
                name: d.node.sys_name,
                rings: []
              };
              return gnodes.push(o);
            }
          };
          for (_i = 0, _len = raw.length; _i < _len; _i++) {
            d = raw[_i];
            _fn(d);
          }
          for (_j = 0, _len1 = raw.length; _j < _len1; _j++) {
            d = raw[_j];
            blkports = [];
            upports = [];
            if (d.ports != null) {
              blkports = (function() {
                var _k, _len2, _ref, _results;
                _ref = d.ports;
                _results = [];
                for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
                  p = _ref[_k];
                  if (p.blocking) {
                    _results.push(p.no);
                  }
                }
                return _results;
              })();
              upports = (function() {
                var _k, _len2, _ref, _results;
                _ref = d.ports;
                _results = [];
                for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
                  p = _ref[_k];
                  if (p.link === 'up') {
                    _results.push(p.no);
                  }
                }
                return _results;
              })();
            }
            if (d.links != null) {
              _ref = d.links;
              for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
                l = _ref[_k];
                if (_ref1 = l.local_port_no, __indexOf.call(upports, _ref1) < 0) {
                  continue;
                }
                if (find_node_idx(l.neighbour_id) < 0) {
                  gnodes.push({
                    mac: l.neighbour_id,
                    ip: l.neighbour_ip_address,
                    location: 'unknown',
                    name: l.neighbour_system_name
                  });
                }
                link = {
                  nodepair: [find_node_idx(l.local_id), find_node_idx(l.neighbour_id)],
                  portpair: [l.local_port_no, l.neighbour_port_no],
                  blocked: (_ref2 = l.local_port_no, __indexOf.call(blkports, _ref2) >= 0)
                };
                add_to_linkset(glinks, link);
                find_dup_n(glinks);
              }
            }
          }
          for (_l = 0, _len3 = raw.length; _l < _len3; _l++) {
            d = raw[_l];
            if (d.rings == null) {
              continue;
            }
            _ref3 = d.rings;
            for (_m = 0, _len4 = _ref3.length; _m < _len4; _m++) {
              r = _ref3[_m];
              if (grings[r.ring_id] == null) {
                grings[r.ring_id] = {
                  id: r.ring_id,
                  type: r.type,
                  state: r.state,
                  nodes: [],
                  links: []
                };
              }
              mring = grings[r.ring_id];
              if (d.node != null) {
                mring.nodes.push({
                  idx: find_node_idx(d.node.local_id),
                  role: r.role
                });
              }
              if (d.node != null) {
                linkidx = find_linkidx(d.node.local_id, r.ring_port_0);
              }
              if (linkidx != null) {
                if (__indexOf.call(mring.links, linkidx) < 0) {
                  mring.links.push(linkidx);
                }
              }
              if (d.node != null) {
                linkidx = find_linkidx(d.node.local_id, r.ring_port_1);
              }
              if (linkidx != null) {
                if (__indexOf.call(mring.links, linkidx) < 0) {
                  mring.links.push(linkidx);
                }
              }
            }
          }
          for (rid in grings) {
            ring = grings[rid];
            _ref4 = ring.nodes;
            for (_n = 0, _len5 = _ref4.length; _n < _len5; _n++) {
              rnode = _ref4[_n];
              node = gnodes[rnode.idx];
              node.rings.push({
                id: ring.id,
                type: ring.type,
                role: rnode.role
              });
            }
            _ref5 = ring.links;
            for (_o = 0, _len6 = _ref5.length; _o < _len6; _o++) {
              rlinkidx = _ref5[_o];
              link = glinks[rlinkidx];
              if (link.rings == null) {
                link.rings = [];
              }
              link.rings.push({
                id: ring.id,
                type: ring.type
              });
            }
          }
          links = [];
          for (i = _p = 0, _len7 = gnodes.length; _p < _len7; i = ++_p) {
            n = gnodes[i];
            n.id = i;
            n.inputConnectors = [];
            n.outputConnectors = [];
          }
          for (_q = 0, _len8 = glinks.length; _q < _len8; _q++) {
            l = glinks[_q];
            links.push({
              source: gnodes[l.nodepair[0]],
              target: gnodes[l.nodepair[1]],
              sourceport: l.portpair[0],
              targetport: l.portpair[1]
            });
          }
          final = {
            nodes: gnodes,
            rings: grings
          };
          final.links = links;
          return this.processPosdata(final, cb);
        },
        processPosdata: function(data, cb) {
          var did_not_call, force, i, n, that;
          that = this;
          did_not_call = true;
          force = d3.layout.force().nodes(data.nodes).links(data.links).charge(-1800).linkDistance(50).size([500, 500]).gravity(0.1).on('tick', function(a) {
            if (a.alpha < 0.0051 && did_not_call === true) {
              did_not_call = false;
              that.finalize(force.nodes(), force.links(), cb);
              return force.stop();
            }
          });
          n = 10000;
          force.start();
          i = 0;
          while (i < n) {
            force.tick();
            ++i;
          }
          return force.stop();
        },
        finalize: function(nodes_w_pos, links_w_pos, cb) {
          var data, link, _i, _j, _len, _len1;
          data = {};
          for (_i = 0, _len = links_w_pos.length; _i < _len; _i++) {
            link = links_w_pos[_i];
            if (link.sourceport > 6 || link.targetport > 6) {
              nodes_w_pos[nodes_w_pos.indexOf(link.source)].outputConnectors.push({
                name: link.sourceport
              });
              nodes_w_pos[nodes_w_pos.indexOf(link.target)].outputConnectors.push({
                name: link.targetport
              });
            } else {
              nodes_w_pos[nodes_w_pos.indexOf(link.source)].inputConnectors.push({
                name: link.sourceport
              });
              nodes_w_pos[nodes_w_pos.indexOf(link.target)].inputConnectors.push({
                name: link.targetport
              });
            }
          }
          for (_j = 0, _len1 = links_w_pos.length; _j < _len1; _j++) {
            link = links_w_pos[_j];
            link.source.nodeID = link.source.id;
            link.source.connectorIndex = link.sourceport;
            link.dest = {};
            link.dest.nodeID = link.target.id;
            link.dest.connectorIndex = link.targetport;
          }
          data.nodes = nodes_w_pos;
          data.connections = links_w_pos;
          return cb(data);
        }
      };
    }
  ]);

}).call(this);

/*
//@ sourceMappingURL=topo_algorithm_service.map
*/
