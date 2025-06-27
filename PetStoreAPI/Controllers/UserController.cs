using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PetStoreAPI.Data;
using PetStoreAPI.Models;
using PetStoreAPI.Dtos;

namespace PetStoreAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly PetStoreContext _context;
        public UserController(PetStoreContext context)
        {
            _context = context;
        }

        // POST: api/user
        [HttpPost]
        public async Task<IActionResult> CreateUser([FromBody] User user)
        {
            await _context.Database.ExecuteSqlRawAsync(
                "CALL add_user({0}, {1})",
                user.UserName ?? (object)DBNull.Value,
                user.UserEmail ?? (object)DBNull.Value);
            return Ok();
        }

        // GET: api/user/{username}
        [HttpGet("{username}")]
        public async Task<IActionResult> GetUserByUsername(string username)
        {
            var users = await _context.Users
                .FromSqlRaw("SELECT user_id, user_name, user_email FROM find_user({0})", username)
                .ToListAsync();
            if (users.Count == 0) return NotFound();
            var user = users[0];
            var dto = new UserDto
            {
                UserId = user.UserId,
                UserName = user.UserName,
                UserEmail = user.UserEmail
            };
            return Ok(dto);
        }

        // PUT: api/user/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(int id, [FromBody] User user)
        {
            await _context.Database.ExecuteSqlRawAsync(
                "CALL update_user({0}, {1}, {2})",
                id,
                user.UserEmail ?? (object)DBNull.Value,
                user.DeactivatedAt ?? (object)DBNull.Value);
            return Ok();
        }

        // DELETE: api/user/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            await _context.Database.ExecuteSqlRawAsync(
                "CALL delete_user({0})",
                id);
            return Ok();
        }

        // POST: api/user/login
        [HttpPost("login")]
        public IActionResult Login()
        {
            // Stub: Implement authentication as needed
            return Ok(new { message = "Login successful" });
        }

        // POST: api/user/logout
        [HttpPost("logout")]
        public IActionResult Logout()
        {
            // Stub: Implement logout as needed
            return Ok(new { message = "Logout successful" });
        }
    }
} 