using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PetStoreAPI.Data;
using PetStoreAPI.Models;
using PetStoreAPI.Dtos;

namespace PetStoreAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class StoreController : ControllerBase
    {
        private readonly PetStoreContext _context;
        public StoreController(PetStoreContext context)
        {
            _context = context;
        }

        // POST: api/store/order
        [HttpPost("order")]
        public async Task<IActionResult> PlaceOrder([FromBody] Order order)
        {
            await _context.Database.ExecuteSqlRawAsync(
                "CALL add_order({0}, {1})",
                order.UserId, order.PetId);
            return Ok();
        }

        // POST: api/store/order/{id}/cancel
        [HttpPost("order/{id}/cancel")]
        public async Task<IActionResult> CancelOrder(int id)
        {
            await _context.Database.ExecuteSqlRawAsync(
                "CALL cancel_order({0})",
                id);
            return Ok();
        }

        // GET: api/store/order/{id}
        [HttpGet("order/{id}")]
        public async Task<IActionResult> GetOrderById(int id)
        {
            var orders = await _context.Set<OrderDetailsDto>()
                .FromSqlRaw("SELECT order_id, user_name, pet_name, order_status FROM get_order({0})", id)
                .ToListAsync();
            if (orders.Count == 0) return NotFound();
            return Ok(orders[0]);
        }
    }
} 