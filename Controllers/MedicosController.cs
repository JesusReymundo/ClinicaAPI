using ClinicaAPI.DTOs;
using ClinicaAPI.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ClinicaAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class MedicosController : ControllerBase
{
    private readonly IMedicoService _medicoService;

    public MedicosController(IMedicoService medicoService)
    {
        _medicoService = medicoService;
    }

    /// <summary>Obtiene todos los médicos registrados</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<MedicoResponseDto>), StatusCodes.Status200OK)]
    public IActionResult ObtenerTodos()
    {
        var medicos = _medicoService.ObtenerTodos();
        return Ok(new { success = true, data = medicos });
    }

    /// <summary>Obtiene un médico por su ID</summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(MedicoResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult ObtenerPorId(int id)
    {
        var medico = _medicoService.ObtenerPorId(id);
        return Ok(new { success = true, data = medico });
    }

    /// <summary>Busca médicos por especialidad</summary>
    [HttpGet("especialidad/{especialidad}")]
    [ProducesResponseType(typeof(IEnumerable<MedicoResponseDto>), StatusCodes.Status200OK)]
    public IActionResult ObtenerPorEspecialidad(string especialidad)
    {
        var medicos = _medicoService.ObtenerPorEspecialidad(especialidad);
        return Ok(new { success = true, data = medicos });
    }

    /// <summary>Registra un nuevo médico</summary>
    [HttpPost]
    [ProducesResponseType(typeof(MedicoResponseDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public IActionResult Crear([FromBody] MedicoCreateDto dto)
    {
        var medico = _medicoService.Crear(dto);
        return CreatedAtAction(nameof(ObtenerPorId), new { id = medico.Id },
            new { success = true, message = "Médico registrado exitosamente", data = medico });
    }

    /// <summary>Actualiza los datos de un médico</summary>
    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(MedicoResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public IActionResult Actualizar(int id, [FromBody] MedicoUpdateDto dto)
    {
        var medico = _medicoService.Actualizar(id, dto);
        return Ok(new { success = true, message = "Médico actualizado exitosamente", data = medico });
    }

    /// <summary>Elimina un médico por su ID</summary>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult Eliminar(int id)
    {
        _medicoService.Eliminar(id);
        return Ok(new { success = true, message = $"Médico con ID {id} eliminado exitosamente" });
    }
}
