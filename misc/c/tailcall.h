/* Macros to help portably use the attributes for tail calls as
 * described at https://blog.reverberate.org/2025/02/10/tail-call-updates.html
 */

#ifndef TAILCALL_H
#define TAILCALL_H

#ifndef __has_attribute         // For backwards compatibility
#define __has_attribute(x) 0
#endif

#if defined(TAILCALL_FAST) && __has_attribute(preserve_none)
#  define PRESERVE_NONE __attribute__((preserve_none))
#else
#  define PRESERVE_NONE
#  ifdef TAILCALL_FAST
#    warning Registers may be preserved.
#  endif
#endif

#if defined(DO_TAILCALL) && __has_attribute(musttail)
#  define TAILCALL(expr) __attribute__((musttail)) return expr
#else
#  define TAILCALL(expr) return expr
#  ifdef DO_TAILCALL
#    warning Tail calls unsupported.
#  endif
#endif

#endif /* TAILCALL_H */