% COMMANDS TO RUN:
% clingo lpc_instance.lp lpc_encoding.lp --text
% clingo lpc_instance.lp lpc_encoding.lp --stats
% clingo lpc_instance.lp lpc_encoding.lp --stats --opt-strategy=usc

package(libc,1).
package(libc,2).
package(glibc,1).
package(gpg,1).
package(gpg,2).
package(gpg,3).
package(kpgp,1).

satisfies(libc,1,c1).
satisfies(libc,2,c1).
satisfies(libc,1,c2).
satisfies(glibc,1,c3).
satisfies(kpgp,1,c4).
satisfies(gpg,1,c5).
satisfies(gpg,2,c5).
satisfies(gpg,3,c5).

depends(gpg,1,c1).
depends(gpg,2,c2).

conflicts(libc,2,c2).
conflicts(gpg,3,c3).

recommends(libc,2,c4).

installed(libc,1).
installed(glibc,1).

request(c5).

utility(delete,1).
utility(change,2).
